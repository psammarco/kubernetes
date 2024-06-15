# Rsyslog application
This app is a baseline for building powerful logging systems using rsyslog to monitor your kubernetes application. It does make use of [CoreDNS](https://github.com/psammarco/kubernetes/tree/master/coredns) for intra-pod domain resolution and a Persistent Volume Claim to store pods logs on your kubernetes cluster.

The project uses two purposely build docker images, one which act as the rsyslog server while the second one forwards everything to the latter. Images can be found on my [DockerHub repo page](https://hub.docker.com/r/latrina/rsyslog).

## Breaking down important points
**deployment.yaml:**

_Dns Server_
This is your _CoreDNS ClusterIP_ while _searches_ should reflect your CoreDNS configuration
```
dnsPolicy: "None"
      dnsConfig:
        nameservers:
        - 10.43.229.169
        searches:
        - intranet.local
```
