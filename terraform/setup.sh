#!/bin/bash
# Update and install necessary packages
sudo apt-get update -y
sudo apt-get upgrade -y

    # Set hostname based on instance tags
HOSTNAME="${count.index == 0 ? "master" : "worker-${count.index}"}"
sudo hostnamectl set-hostname $HOSTNAME
# Step 2: Install kubelet, kubeadm, and kubectl
sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
kubectl version --client && kubeadm version

# Step 3: Disable Firewall & Swap
sudo ufw disable
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
sudo mount -a
free -h

# Step 4: Install Container Runtime (Containerd)
echo -e "overlay\nbr_netfilter" | sudo tee /etc/modules-load.d/containerd.conf
sudo modprobe overlay && sudo modprobe br_netfilter
echo -e "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/kubernetes.conf
sudo sysctl --system
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status containerd

    # If this is the master node
if [ "$(hostname)" == "master" ]; then
    # Step 5: Initialize the Master Node
    sudo systemctl enable kubelet
    sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock
    INSTANCE_PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

    sudo kubeadm init --apiserver-advertise-address=$INSTANCE_PRIVATE_IP --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=all
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Step 6: Install Network Plugin on the Master (Calico)
    sudo kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
    sudo kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml
    # watch kubectl get pods --all-namespaces
      # Output the join command for the worker nodes
    sudo kubeadm token create --print-join-command > /home/ubuntu/kubeadm_join_command.sh
    sudo chmod +x /home/ubuntu/kubeadm_join_command.sh
else
      # Wait until the join command script is available from the master
      while [ ! -f /home/ubuntu/kubeadm_join_command.sh ]; do
        sleep 10
      done

      # Join the Kubernetes cluster
      sudo bash /home/ubuntu/kubeadm_join_command.sh
fi