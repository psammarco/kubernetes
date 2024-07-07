# RELP-Rsyslog demo application
This is a two nodes relp-rsyslog server which uses relp-openssl to handle TLS authentication.

This app serves as a foundation for building robust logging systems using relp-rsyslog to monitor your Kubernetes applications. It utilizes [CoreDNS](https://github.com/psammarco/kubernetes/tree/master/coredns) for intra-pod domain resolution and a Persistent Volume Claim to store pod logs within your Kubernetes cluster.

The project includes two custom-built Docker images: one acts as the rsyslog server, while the other forwards logs to the server. You can find these images on my [DockerHub repo page](https://hub.docker.com/r/latrina/relp-rsyslog).

## Breaking down key points
**pods.yaml:**

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

This configuration mounts the _/var/log_ directory of your pod to a Persistent Volume Claim (PVC) named ***relp-storage***. The logs are stored in a subdirectory named after the pod's UID.
It also declares the mountpoint for both rsyslog.conf and ssl certificates configmaps.
```
volumeMounts:
        - name: relp-storage
          mountPath: "/var/log"
          readOnly: false
          subPathExpr: "$(POD_UID)"
        - name: config-volume
          mountPath: /etc/rsyslog
        - name: certs-volume
          mountPath: /rsyslog-certs
      env:
        - name: POD_UID
          valueFrom:
            fieldRef:
              fieldPath: metadata.uid
```
PVC and configmaps must also be declared in the ***Volumes*** section.
```
volumes:
    - name: relp-storage
      persistentVolumeClaim:
        claimName: relp-storage
    - name: config-volume
      configMap:
        name: rsyslog-config
        items:
          - key: rsyslog.conf
            path: rsyslog.conf
    - name: certs-volume
      configMap:
        name: certs-config
        items:
          - key: ca-cert.pem
            path: ca-cert.pem
          - key: server-cert.pem
            path: server-cert.pem
          - key: server-key.pem
            path: server-key.pem
```
**pv.yaml**

Creates a RW _storageClassName_ called ***relp-store*** where _hostPath_ (the volume) is mounted on _/opt/PVs/relp-rsyslog_ of the node where both PVC and pod are deployed.
```
 accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: relp-store 
  hostPath:
    path: /opt/PVs/relp-rsyslog
```

## Client configuration
***Statefulset*** is used as we require predictable naming for the pods in order to take advantage of CoreDNS functionalities and for TLS authentication.

The application uses *"RSYSLOGSRV_CENTRAL"* and *"RSYSLOGSRV_SECONDARY"* environment variables to set the rsyslog servers domain names.

Fore more info on the rsyslog client configuration see the docker image [Github page](https://github.com/psammarco/dockerhub/tree/main/relp-rsyslog/rsyslog-client). Instructions on how to generate the SSL certificates can be found in [genkeys.tar.gz](https://github.com/psammarco/kubernetes/blob/master/relp-rsyslog/genkeys.tar.gz).
