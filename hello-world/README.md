# What does it do?
Creates the hello-world application which is a 3 replicas simple nginx http server that uses a headless network configuration. 
In addition it creates a HAproxy load balancer which resolves the hello-world application through any one of the pod IPs which are part of the service headless endpoint.

## How does DNS resolution work?
There is no magic DNS server setup in place, but rather a neat workaround for fast deployments/ POC.
By using a service headless setup together with HAproxy pods are created using a predictable domain name which is then resolved roundrobin with any of the service endpoint pods IP.

## Replica naming predictability
```
apiVersion: v1
kind: Service
metadata:
  name: www 
spec:
  clusterIP: None
  selector:
    app: hello-world
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

