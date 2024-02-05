# What does it do?
Creates the hello-world application which is a 3 replicas simple nginx http server that uses a headless network configuration. 
In addition it creates a HAproxy load balancer which resolves the hello-world application through any one of the pod IPs which are part of the service headless endpoint.

## How does DNS resolution work?
There is no magic DNS server setup in place, but rather a neat workaround for fast deployments/ POC.
By using a service headless setup together with HAproxy pods are created using a predictable domain name which is then resolved roundrobin with any of the service endpoint pods IP.

## Replica naming predictability
From the headless service code below we can see that the endpoint name is www.
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
This can be verified using the `kubectl get endpoints` command
```
NAME          ENDPOINTS                                   AGE
kubernetes    172.12.0.200:6443                           20d
hello-world   10.42.1.55:80,10.42.3.32:80,10.42.4.36:80   5d23h
www           10.42.1.55:80,10.42.3.32:80,10.42.4.36:80   3h2m
```

