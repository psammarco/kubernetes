# What does it do?
Creates the hello-world application which is a 3 replicas simple nginx http server that uses a headless network configuration. 
In addition it creates a HAproxy load balancer which resolves the hello-world application through any one of the pod IPs which are part of the service headless endpoint.

## How does DNS resolution work?
There is no magic DNS server setup in place, but rather a neat workaround for fast deployments/ POC.
By using a service headless setup together with HAproxy pods are created using a predictable domain name which is then resolved roundrobin with any of the service endpoint pods IP.

## Replica naming predictability
From the headless service code below we can see that the endpoint name is *www*. 
This mean that replicas of the hello-world application will be named *www0*, *www1* and *www2*.
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
The `www` endpoint can be verified using the `kubectl get endpoints` command
```
NAME          ENDPOINTS                                   AGE
kubernetes    172.12.0.200:6443                           20d
hello-world   10.42.1.55:80,10.42.3.32:80,10.42.4.36:80   5d23h
www           10.42.1.55:80,10.42.3.32:80,10.42.4.36:80   3h2m
```
## HAproxy loadbalancer not so dynamic resolution
As stated above this application is not using any fancy DNS server setup to magically resolve the pods, but instead relies on the headless service naming convention together with the `server-template` option in haproxy.cfg, plus a static domain name for **k3s.intranet.local** which points to any of the pods `www` endpoint IP.

The `server-template` option found in haproxy.cfg basically tells the load balancer to resolve 3 `www` domain name under the **k3s.intranet.local**  FQDN.
Because of this it will use the naming convention applied with the headless service. 
``` 
backend hello-world
      balance roundrobin
      server-template www 3 k3s.intranet.local:80 check
```

In addition we add **k3s.intranet.local** to the HAproxy pod's /etc/hosts in order to resolve any of the pods `www` endpoint IP. The loadbalancer will then go roundrobin between the replicas.
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-hosts
data:
  hosts: |
    10.42.1.55 k3s.intranet.local
```

## Is this all DNS resolution thing not inconvenient?
In a sense it is as you need to either delay the deployment of haproxy or delete it and redeploy it as soon as you have one of the pods `www` endpoint IP.
On the positive side it saves you a bit of time by not having to declare each replica manually in haproxy.cfg, which it may not sound like a big deal for just 3 replicas, but imagine if you had dozens? It also saves you some time ....
