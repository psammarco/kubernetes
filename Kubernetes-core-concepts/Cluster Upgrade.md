Cluster Upgrade
Upgrade Controlplane

Upgrade the controlplane Node to a newer patch version.

Also upgrade kubectl and kubelet .

Tip 1

    Kubernetes versions are expressed as x.y.z, where x is the major version, y is the minor version, and z is the patch version 

https://kubernetes.io/releases/version-skew-policy

# see current versions
kubectl get node
kubectl version


Tip 2

kubeadm upgrade -h


Tip 3

Install the correct kubeadm version:

# show available versions
apt-cache show kubeadm


Solution

We are already on controlplane :

# see possible versions
kubeadm upgrade plan

# show available versions
apt-cache show kubeadm

# can be different for you
apt-get install kubeadm=1.31.1-1.1

# could be a different version for you, it can also take a bit to finish!
kubeadm upgrade apply v1.31.1


Next we update kubectl and kubelet :

# can be a different version for you
apt-get install kubectl=1.31.1-1.1 kubelet=1.31.1-1.1

service kubelet restart

## my method

controlplane $ cat update.sh 
apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm='1.31.1-1.1' && \
apt-mark hold kubeadm

kubeadm upgrade plan
kubeadm upgrade apply v1.31.1
controlplane $ cat node.sh 
apt-mark unhold kubelet kubectl && \
apt-get update &&  apt-get install -y kubelet='1.31.1-1.1' kubectl='1.31.1-1.1' && \
apt-mark hold kubelet kubectl


## Upgrade Worker

Upgrade Node node01 to the same version as controlplane .

Tip

ssh node01
    kubeadm upgrade -h


Solution

ssh node01
    # can be a different version for you
    apt-get install kubeadm=1.31.1-1.1
    kubeadm upgrade node


Next we update kubectl and kubelet :

ssh node01
    # can be a different version for you
    apt-get install kubelet=1.31.1-1.1
    
    service kubelet restart


