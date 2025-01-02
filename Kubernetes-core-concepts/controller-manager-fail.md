Kube Controller Manager Misconfigured
It is crashing, fix it

A custom Kube Controller Manager container image was running in this cluster for testing. It has been reverted back to the default one, but it's not coming back up. Fix it.

Log Locations

Log locations to check:

    kubectl log
    /var/log/pods
    /var/log/containers
    crictl ps + crictl logs
    docker ps + docker logs (in case when Docker is used)
    kubelet logs: /var/log/syslog or journalctl


Tip 1

The issue might be wrong or unknown arguments passed to the process, remove those and make sure the Pod is running and ready again.

Tip 2

For your changes to apply you might have to:

    move the kube-controller-manager.yaml out of the manifests directory
    wait for the container to be gone (watch crictl ps )
    move the manifest back in and wait for the container coming back up

Some users report that they need to restart the kubelet (service kubelet restart ) but in theory this shouldn't be necessary.

Solution

We can see the kuber-controller-manager Pod is crashing:

kubectl -n kube-system get pod


We should check the logs:

kubectl -n kube-system logs kube-controller-manager-controlplane


It shows us the error:

Error: unknown flag: --project-sidecar-insertion


We could also check:

/var/log/pods/kube-system_kube-controller-manager-controlplane_*/kube-controller-manager/*.log


To fix we remove the unknown argument in /etc/kubernetes/manifests/kube-controller-manager.yaml :

apiVersion: v1
kind: Pod
metadata:
...
  name: kube-controller-manager
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-controller-manager
    - --allocate-node-cidrs=true
    - --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf
    - --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf
    - --bind-address=127.0.0.1
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --cluster-cidr=192.168.0.0/16
    - --cluster-name=kubernetes
    - --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
    - --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
    - --controllers=*,bootstrapsigner,tokencleaner
    - --kubeconfig=/etc/kubernetes/controller-manager.conf
    - --leader-elect=true
    - --project-sidecar-insertion=true # REMOVE
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt


If we wait some time the Pod should start again, or we force restart via kubelet by moving the manifest out of the manifest directory:

cd /etc/kubernetes/manifests
mv kube-controller-manager.yaml ..
sleep 5
mv ../kube-controller-manager.yaml .


We need to wait till the Pod is Running and all containers are Ready.
