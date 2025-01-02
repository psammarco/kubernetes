Apiserver Crash
Configure a wrong argument

The idea here is to misconfigure the Apiserver in different ways, then check possible log locations for errors.

You should be very comfortable with situations where the Apiserver is not coming back up.

Configure the Apiserver manifest with a new argument --this-is-very-wrong .

Check if the Pod comes back up and what logs this causes.

Fix the Apiserver again.

Log Locations

Log locations to check:

    /var/log/pods
    /var/log/containers
    crictl ps + crictl logs
    docker ps + docker logs (in case when Docker is used)
    kubelet logs: /var/log/syslog or journalctl


Solution

# always make a backup !
cp /etc/kubernetes/manifests/kube-apiserver.yaml ~/kube-apiserver.yaml.ori

# make the change
vim /etc/kubernetes/manifests/kube-apiserver.yaml

# wait till container restarts
watch crictl ps

# check for apiserver pod
k -n kube-system get pod


Apiserver is not coming back, we messed up!

# check pod logs
cat /var/log/pods/kube-system_kube-apiserver-controlplane_a3a455d471f833137588e71658e739da/kube-apiserver/X.log
> 2022-01-26T10:41:12.401641185Z stderr F Error: unknown flag: --this-is-very-wrong


Now undo the change and continue

# smart people use a backup
cp ~/kube-apiserver.yaml.ori /etc/kubernetes/manifests/kube-apiserver.yaml


------
Misconfigure ETCD connection

Change the existing Apiserver manifest argument to: --etcd-servers=this-is-very-wrong .

Check what the logs say, without using anything in /var .

Fix the Apiserver again.

Log Locations

Log locations to check:

    /var/log/pods
    /var/log/containers
    crictl ps + crictl logs
    docker ps + docker logs (in case when Docker is used)
    kubelet logs: /var/log/syslog or journalctl


Solution

# always make a backup !
cp /etc/kubernetes/manifests/kube-apiserver.yaml ~/kube-apiserver.yaml.ori

# make the change
vim /etc/kubernetes/manifests/kube-apiserver.yaml

# wait till container restarts
watch crictl ps

# check for apiserver pod
k -n kube-system get pod


Apiserver is not coming back, we messed up!

# 1) if we would check the /var directory
cat /var/log/pods/kube-system_kube-apiserver-controlplane_e24b3821e9bdc47a91209bfb04056993/kube-apiserver/X.log
> Err: connection error: desc = "transport: Error while dialing dial tcp: address this-is-very-wrong: missing port in address". Reconnecting...

# 2) but here we want to find other ways, so we check the container logs
crictl ps # maybe run a few times, because the apiserver container get's restarted
crictl logs f669a6f3afda2
> Error while dialing dial tcp: address this-is-very-wrong: missing port in address. Reconnecting...

# 3) what about syslogs
journalctl | grep apiserver # nothing specific
cat /var/log/syslog | grep apiserver # nothing specific


Now undo the change and continue

# smart people use a backup
cp ~/kube-apiserver.yaml.ori /etc/kubernetes/manifests/kube-apiserver.yaml


-----

Invalid Apiserver Manifest YAML

Change the Apiserver manifest and add invalid YAML, something like this:

apiVersionTHIS IS VERY ::::: WRONG v1
kind: Pod
metadata:

Check what the logs say.

Fix the Apiserver again.

Log Locations

Log locations to check:

    /var/log/pods
    /var/log/containers
    crictl ps + crictl logs
    docker ps + docker logs (in case when Docker is used)
    kubelet logs: /var/log/syslog or journalctl


Solution

# always make a backup !
cp /etc/kubernetes/manifests/kube-apiserver.yaml ~/kube-apiserver.yaml.ori

# make the change
vim /etc/kubernetes/manifests/kube-apiserver.yaml

# wait till container restarts
watch crictl ps

# check for apiserver pod
k -n kube-system get pod


Apiserver is not coming back, we messed up!

# seems like the kubelet can't even create the apiserver pod/container
/var/log/pods # nothing
crictl logs # nothing

# syslogs:
tail -f /var/log/syslog | grep apiserver
> Could not process manifest file err="/etc/kubernetes/manifests/kube-apiserver.yaml: couldn't parse as pod(yaml: mapping values are not allowed in this context), please check config file"

# or:
journalctl | grep apiserver
> Could not process manifest file" err="/etc/kubernetes/manifests/kube-apiserver.yaml: couldn't parse as pod(yaml: mapping values are not allowed in this context), please check config file


Now undo the change and continue

# smart people use a backup
cp ~/kube-apiserver.yaml.ori /etc/kubernetes/manifests/kube-apiserver.yaml