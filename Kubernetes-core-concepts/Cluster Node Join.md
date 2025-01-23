Cluster Node Join
Join Node using Kubeadm

The Node node01 is not yet part of the cluster, join it using kubeadm.

Tip 1

First run a command on the controlplane to get a join command. Then execute that command on the node.

Tip 2

kubeadm token -h


Tip 3

kubeadm token create --print-join-command


Solution

We are already on the controlplane Node, so we don't have to ssh into it.

kubectl get node # only the controlplane node available

kubeadm token create --print-join-command

ssh node01
    # execute command printed out by command above
    kubeadm join 172.30.1.2:6443 --token ...
    exit

kubectl get node # should show the node

