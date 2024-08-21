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

resource "aws_instance" "example" {
  count           = 3
  ami             = "ami-08aa7f71c822e5cc9" # Ubuntu AMI
  instance_type   = "t2.large"
  security_groups = [aws_security_group.control_plane_sg.name]
  key_name        = aws_key_pair.deployer.key_name
  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "${count.index == 0 ? "master" : "worker-${count.index}"}"
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
    HOSTNAME="${count.index == 0 ? "master" : "worker-${count.index}"}"
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


    

    # If this is the master node
    if [ "$(hostname)" == "master" ]; then
    sudo systemctl enable kubelet
    sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock
    INSTANCE_PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)


    sudo kubeadm init --apiserver-advertise-address=$INSTANCE_PRIVATE_IP --pod-network-cidr=192.168.0.0/16 
    sleep 15

    echo "installing calico"
    export KUBECONFIG=/etc/kubernetes/admin.conf

    # Step 6: Install Network Plugin on the Master (Calico)
    sudo kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml 
    sudo kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml
    sudo kubectl create -f custom-resources.yaml

    # watch kubectl get pods --all-namespaces
        # Output the join command for the worker nodes
    sudo kubeadm token create --print-join-command > /home/ubuntu/kubeadm_join_command.sh
    sudo chmod +x /home/ubuntu/kubeadm_join_command.sh

    echo "installing ks9 dashboard"
    curl -sS https://webinstall.dev/k9s | bash
    source ~/.config/envman/PATH.env
    k9s version

    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
    helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

    helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard


    else
        sudo systemctl enable kubelet
        sudo mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
    fi
  EOF
}

output "instance_public_ips" {
  value = aws_instance.example[*].public_ip
}


