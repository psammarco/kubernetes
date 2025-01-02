logo

PLUS

    Areas
    Account
    Creator
    Logout 

Kubelet Misconfigured
Someone tried to improve the Kubelet, but broke it instead

Someone tried to improve the Kubelet on Node node01 , but broke it instead. Fix it.

Log Locations

Log locations to check:

    kubelet logs: /var/log/syslog or journalctl


Tip 1

ssh node01
    service kubelet status


Tip 2

ssh node01
    cat /var/log/syslog | grep kubelet


Tip 3

ssh node01
    # maybe any interesting config files?
    find / | grep kubeadm


Solution

The status is showing a failure:

ssh node01
    service kubelet status


We should check the logs:

grep kubelet /var/log/syslog


It shows us the error:

Feb 21 16:50:41 node01 kubelet[9516]: E0221 16:50:41.994746    9516 run.go:74] "command failed"
err="failed to parse kubelet flag: unknown flag: --improve-speed"


To fix we remove the unknown flag in /var/lib/kubelet/kubeadm-flags.env :

KUBELET_KUBEADM_ARGS="--container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.9"


And the status should be good again:

service kubelet restart

service kubelet status


    Exam Desktop
    Editor
    Tab 1
    +

53 min

