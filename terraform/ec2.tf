






resource "aws_instance" "master" {
  ami                    = "ami-08aa7f71c822e5cc9" # Ubuntu AMI
  instance_type          = var.instance_type_master
  vpc_security_group_ids = [aws_security_group.control_plane_sg.id]
  key_name               = aws_key_pair.deployer.key_name
  root_block_device {
    volume_size = 20
  }
  subnet_id            = module.vpc.public_subnets[0]
  iam_instance_profile = aws_iam_instance_profile.master.name
  tags = {
    Name                     = "master"
    "kubernetes.io/cluster/" = "bruvio"

  }
  associate_public_ip_address = true
  private_dns_name_options {
    hostname_type = "resource-name"
  }

  user_data = <<-EOF
    #!/bin/bash
    CLUSTER_NAME="bruvio"
    K8S_VERSION="1.31.0"
    REGION="eu-west-2"
    VPC_ID="${module.vpc.vpc_id}"
    SERVICE_ACCOUNT="aws-load-balancer-controller"
    NAMESPACE="kube-system"
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # Set hostname based on index∫
    HOSTNAME="master"
    sudo hostnamectl set-hostname $HOSTNAME
    sudo systemctl restart systemd-hostnamed

    # Install Docker
    sudo apt-get install -y docker.io
    sudo echo '{"exec-opts": ["native.cgroupdriver=systemd"], "log-driver": "json-file", "log-opts": {"max-size": "100m"}, "storage-driver": "overlay2"}' > /etc/docker/daemon.json
    sudo systemctl enable docker
    sudo systemctl start docker

    # Install Kubernetes packages
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg awscli bash-completion
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list





    sudo apt-get update
    sudo apt-get install -y kubelet==1.31.0-1.1 kubeadm==1.31.0-1.1 kubectl==1.31.0-1.1 vim git curl wget 
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
    # echo -e "[Global]\nRegion = eu-west-2" | sudo tee /etc/kubernetes/aws.conf

 
    sudo kubeadm init  --apiserver-advertise-address=$INSTANCE_PRIVATE_IP --pod-network-cidr=192.168.0.0/16 
    sudo mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config


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
    sudo echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc


    # # Install Helm
    # echo "### Installing Helm ###"
    # curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

    # Add the AWS EKS Helm chart repository (for AWS Load Balancer Controller)
    echo "### Adding AWS EKS Helm chart repository ###"
    sudo helm repo add eks https://aws.github.io/eks-charts
    sudo helm repo update

    # Create the IAM role and service account for the AWS Load Balancer Controller
    echo "### Creating IAM role and service account ###"
    sudo kubectl create namespace $NAMESPACE

    sudo bash -c 'cat > aws-lb-controller-sa.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::546123287190:role/ec2-role
EOF' && sudo kubectl apply -f aws-lb-controller-sa.yaml

    sudo kubectl apply -f serviceaccount.yaml
    # Install the AWS Load Balancer Controller
    echo "### Installing AWS Load Balancer Controller ###"
    sudo helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
      -n $NAMESPACE \
      --set clusterName=$CLUSTER_NAME \
      --set serviceAccount.create=false \
      --set serviceAccount.name=$SERVICE_ACCOUNT \
      --set region=$REGION \
      --set vpcId=$VPC_ID

    # Taint master nodes to allow scheduling on them (optional for small setups)
    sudo kubectl taint nodes master node-role.kubernetes.io/control-plane:NoSchedule-

    echo "### Kubernetes cluster setup with Cloud Controller Manager is complete ###"

    echo "### You can now use kubectl to interact with your cluster ###"


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
  depends_on = [aws_security_group.control_plane_sg, module.vpc]
}

# provider "time" {}

# resource "time_sleep" "wait" {
#   create_duration = "245s"
# }

resource "aws_instance" "workers" {
  count                  = 2
  ami                    = "ami-08aa7f71c822e5cc9" # Ubuntu AMI
  instance_type          = var.instance_type_worker
  vpc_security_group_ids = [aws_security_group.control_plane_sg.id]
  key_name               = aws_key_pair.deployer.key_name
  root_block_device {
    volume_size = 20
  }
  subnet_id            = module.vpc.public_subnets[count.index]
  iam_instance_profile = aws_iam_instance_profile.worker.name
  tags = {
    Name                     = "worker-${count.index + 1}"
    "kubernetes.io/cluster/" = "bruvio"
  }
  associate_public_ip_address = true
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
    sudo echo '{"exec-opts": ["native.cgroupdriver=systemd"], "log-driver": "json-file", "log-opts": {"max-size": "100m"}, "storage-driver": "overlay2"}' > /etc/docker/daemon.json

    sudo systemctl enable docker
    sudo systemctl start docker

    # Install Kubernetes packages
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg awscli bash-completion
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list





    sudo apt-get update
    sudo apt-get install -y kubelet==1.31.0-1.1 kubeadm==1.31.0-1.1 kubectl==1.31.0-1.1 vim git curl wget 
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










