# Rsyslog demo application
This app serves as a foundation for building robust logging systems using rsyslog to monitor your Kubernetes applications. It utilizes [CoreDNS](https://github.com/psammarco/kubernetes/tree/master/coredns) for intra-pod domain resolution and a Persistent Volume Claim to store pod logs within your Kubernetes cluster.

The project includes two custom-built Docker images: one acts as the rsyslog server, while the other forwards logs to the server. You can find these images on my [DockerHub repo page](https://hub.docker.com/r/latrina/rsyslog).

## Breaking down key points
**deployment.yaml:**

_Dns Server:_

This is your _CoreDNS ClusterIP_ while the _searches_ option should reflect your CoreDNS configuration
```
dnsPolicy: "None"
      dnsConfig:
        nameservers:
        - 10.43.229.169
        searches:
        - intranet.local
```

_volumeMounts:_

This configuration mounts the _/var/log_ directory of your pod to a Persistent Volume Claim (PVC) named ***data***. The logs are stored in a subdirectory named after the pod's UID.
```
volumeMounts:
          - name: data 
            mountPath: "/var/log"
            readOnly: false
            subPathExpr: "$(POD_UID)"
env:
          - name: POD_UID 
            valueFrom:
              fieldRef:
                fieldPath: metadata.uid
```

**pv.yaml**

Creates a RW _storageClassName_ called ***store-tmp*** where _hostPath_ (the volume) is mounted on _/opt/PV_ of the node where both PVC and pod are deployed.
```
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: store-tmp
  hostPath:
    path: /opt/PV
```
