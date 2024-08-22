provider "aws" {
  region  = "eu-west-2"
  profile = "masterbruvio"
}

variable "key-name" {
  default = "deployer-key"
}
resource "aws_security_group" "control_plane_sg" {
  name        = "control-plane-sg"
  description = "Security group for the control plane"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "control-plane-sg"
  }
}

# investigate following security group settings following documentation

# resource "aws_security_group" "control_plane_sg" {
#   name        = "control-plane-sg"
#   description = "Security group for the control plane"

#   # SSH from your local machine (only your IP address is allowed)
#   ingress {
#     description = "Allow SSH from my local machine"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]

#   }

#   # API server accessible by anyone
#   ingress {
#     description = "Allow access to API server"
#     from_port   = 6443
#     to_port     = 6443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # etcd server client API accessible only within the private network
#   ingress {
#     description = "Allow etcd server client API on private network"
#     from_port   = 2379
#     to_port     = 2380
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]

#   }
#   ingress {
#     description = "Allow etcd server client API on private network"
#     from_port   = 8080
#     to_port     = 9000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]

#   }
#   # Kubelet, kube-scheduler, kube-controller on private network only
#   ingress {
#     description = "Allow kubelet, scheduler, and controller access on private network"
#     from_port   = 10250
#     to_port     = 10259
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]

#   }

#   # Egress rule to allow all outbound traffic to anywhere (IPv4)
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"] # Allows outbound traffic to anywhere over IPv4
#   }

# tags = {
#   Name = "control-plane-sg"
# }
# }

resource "aws_key_pair" "deployer" {
  key_name   = var.key-name
  public_key = file("${path.module}/deployer_key.pub")
}

resource "aws_iam_instance_profile" "example" {
  name = "example-instance-profile"
  role = aws_iam_role.example.name
}

resource "aws_instance" "master" {
  ami             = "ami-08aa7f71c822e5cc9" # Ubuntu AMI
  instance_type   = "t2.large"
  security_groups = [aws_security_group.control_plane_sg.name]
  key_name        = aws_key_pair.deployer.key_name
  root_block_device {
    volume_size = 20
  }
  iam_instance_profile = aws_iam_instance_profile.example.name
  tags = {
    Name = "master"
  }
  private_dns_name_options {
    hostname_type = "resource-name"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # Set hostname based on index∫
    HOSTNAME="master"
    sudo hostnamectl set-hostname $HOSTNAME
    sudo systemctl restart systemd-hostnamed

    # Install Docker
    sudo apt-get install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker

    # Install Kubernetes packages
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg awscli bash-completion
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list





    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl vim git curl wget 
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet

    sudo ufw disable
    # Disable swap
    sudo swapoff -a
    sudo sed -i '/ swap / s/^/#/' /etc/fstab
    modprobe overlay
    modprobe br_netfilter
    echo -e "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/kubernetes.conf


    
    sudo systemctl enable kubelet
    sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock
    INSTANCE_PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)


    sudo kubeadm init --apiserver-advertise-address=$INSTANCE_PRIVATE_IP --pod-network-cidr=192.168.0.0/16 

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    sleep 15

    echo "installing calico"
    sudo su
    export KUBECONFIG=/etc/kubernetes/admin.conf
    

    # Step 6: Install Network Plugin on the Master (Calico)
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml 
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml
    kubectl create -f custom-resources.yaml


    # Output the join command for the worker nodes
    kubeadm token create --print-join-command > /home/ubuntu/kubeadm_join_command.sh
    chmod +x /home/ubuntu/kubeadm_join_command.sh
    aws s3 cp /home/ubuntu/kubeadm_join_command.sh s3://${random_pet.bucket_name.id}/kubeadm_join_command.sh

    echo "installing ks9 dashboard"
    curl -sS https://webinstall.dev/k9s | bash
    source ~/.config/envman/PATH.env
    k9s version

    echo "installing kubernetes dashboard via helm"
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    apt-get update
    apt-get install helm
    helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

    helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

    # copy all files from s3 to the master node
    aws s3 cp  s3://${random_pet.bucket_name.id}/ /home/ubuntu/ --recursive


  EOF

  provisioner "remote-exec" {
    inline = [
      "/bin/bash -c \"timeout 300 sed '/finished at/q' <(tail -f /var/log/cloud-init-output.log)\""
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("deployer_key")
      host        = self.public_ip
    }
  }
}

# provider "time" {}

# resource "time_sleep" "wait" {
#   create_duration = "245s"
# }

resource "aws_instance" "workers" {
  count           = 2
  ami             = "ami-08aa7f71c822e5cc9" # Ubuntu AMI
  instance_type   = "t2.large"
  security_groups = [aws_security_group.control_plane_sg.name]
  key_name        = aws_key_pair.deployer.key_name
  root_block_device {
    volume_size = 20
  }
  iam_instance_profile = aws_iam_instance_profile.example.name
  tags = {
    Name = "worker-${count.index + 1}"
  }
  private_dns_name_options {
    hostname_type = "resource-name"
  }
  #  to install Client Version: v1.31.0
  # Kustomize Version: v5.4.2
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # Set hostname based on index∫
    HOSTNAME="worker-${count.index + 1}"
    sudo hostnamectl set-hostname $HOSTNAME
    sudo systemctl restart systemd-hostnamed

    # Install Docker
    sudo apt-get install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker

    # Install Kubernetes packages
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg awscli bash-completion
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list





    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl vim git curl wget 
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet

    sudo ufw disable
    # Disable swap
    sudo swapoff -a
    sudo sed -i '/ swap / s/^/#/' /etc/fstab
    modprobe overlay
    modprobe br_netfilter
    echo -e "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/kubernetes.conf



    sudo systemctl enable kubelet
    aws s3 cp  s3://${random_pet.bucket_name.id}/kubeadm_join_command.sh /home/ubuntu/kubeadm_join_command.sh
    sudo ./kubeadm_join_command.sh
    
  EOF
  # depends_on = [aws_instance.master,time_sleep.wait]
  depends_on = [aws_instance.master]
}



output "master_public_ips" {
  value = aws_instance.master.public_ip
}
output "workers_public_ips" {
  value = aws_instance.workers[*].public_ip
}

# Generate a random bucket name
resource "random_pet" "bucket_name" {
  length = 2
}
resource "aws_s3_bucket" "this" {
  bucket        = random_pet.bucket_name.id
  force_destroy = true
}


resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}
# Upload files recursively from both folders
resource "aws_s3_bucket_object" "folder1" {
  for_each = fileset(var.folder1_path, "**/*")

  bucket = aws_s3_bucket.this.id
  key    = each.key
  source = "${var.folder1_path}/${each.key}"
  acl    = "private"
  etag   = filemd5("${var.folder1_path}/${each.key}")
}

resource "aws_s3_bucket_object" "folder2" {
  for_each = fileset(var.folder2_path, "**/*")

  bucket = aws_s3_bucket.this.id
  key    = each.key
  source = "${var.folder2_path}/${each.key}"
  acl    = "private"
  etag   = filemd5("${var.folder2_path}/${each.key}")
}

resource "aws_s3_bucket_object" "setup" {


  bucket = aws_s3_bucket.this.id
  key    = "setup_ks8.sh"   # The destination path in S3
  source = "./setup_ks8.sh" # The path to the file on your local machine

  acl  = "private"
  etag = filemd5("./setup_ks8.sh")
}

variable "folder1_path" {
  type    = string
  default = "../simple"
}

variable "folder2_path" {
  type    = string
  default = "../helloHttpd"
}
variable "versioning" {
  type    = bool
  default = false
}


resource "aws_iam_role" "example" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "example" {
  name = "example-policy"
  role = aws_iam_role.example.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:*",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
    ],
  })
}
