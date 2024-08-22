#!/bin/bash
# Update and install necessary packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Set hostname based on instance tags
HOSTNAME="${count.index == 0 ? "master" : "worker-${count.index}"}"
sudo hostnamectl set-hostname $HOSTNAME


# Install Docker
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Install Kubernetes packages
sudo apt-get install -y apt-transport-https ca-certificates curl gpg awscli
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

# Determine node type (master or worker) based on hostname
HOSTNAME=$(hostname)
sudo systemctl restart systemd-hostnamed

# If this is the master node
if [ "$(hostname)" == "master" ]; then
sudo systemctl enable kubelet
sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock
INSTANCE_PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
# sudo kubeadm init --pod-network-cidr=192.168.0.0/16
sudo kubeadm init --apiserver-advertise-address=$INSTANCE_PRIVATE_IP --pod-network-cidr=192.168.0.0/16 
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Step 6: Install Network Plugin on the Master (Calico)
sudo kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml 
sudo kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml
# watch kubectl get pods --all-namespaces
    # Output the join command for the worker nodes
sudo kubeadm token create --print-join-command > /home/ubuntu/kubeadm_join_command.sh
sudo chmod +x /home/ubuntu/kubeadm_join_command.sh

aws s3 cp /home/ubuntu/kubeadm_join_command.sh s3://${random_pet.bucket_name.id}/kubeadm_join_command.sh

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
    # Wait until the join command script is available from the master
    while [ ! -f /home/ubuntu/kubeadm_join_command.sh ]; do
    sleep 10
    done

    # Join the Kubernetes cluster
    sudo bash /home/ubuntu/kubeadm_join_command.sh
fi