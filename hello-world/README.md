# What does it do?
This configuration deploys the hello-world application, consisting of a simple nginx HTTP server with 3 replicas, each using a headless network configuration. Additionally, it sets up an HAProxy load balancer responsible for resolving the hello-world application through any of the pod IPs associated with the service's headless endpoin

## How does DNS resolution work?
Instead of relying on a traditional DNS server setup, this implementation employs a easy workaround designed for rapid deployments or proof-of-concept scenarios. Through a headless service setup combined with HAProxy pods, a predictable domain name is assigned to each pod. This domain name is then resolved in a round-robin fashion with the IP addresses of the pods associated with the service endpoint.

## Replica naming predictability
The code below shows the endpoint name for our hello-world application is *www*. 
As result of this, replicas of the hello-world application will follow a predictable naming pattern, specifically `www0`, `www1`, and `www2`.
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
Endpoint routes can be shown by using the `kubectl get endpoints` command
```
NAME          ENDPOINTS                                   AGE
kubernetes    172.12.0.200:6443                           20d
hello-world   10.42.1.55:80,10.42.3.32:80,10.42.4.36:80   5d23h
www           10.42.1.55:80,10.42.3.32:80,10.42.4.36:80   3h2m
```
## HAproxy loadbalancer not so dynamic resolution
Instead of relying on an intricate DNS server setup for dynamic pod resolution, this application employs a straightforward approach. It capitalizes on the headless service's naming convention, together with the `server-template` option in `haproxy.cfg`. Additionally, a static domain name, **k3s.intranet.local**, is configured to point to the IP of any pod within the `www` endpoint.

The `server-template` option in `haproxy.cfg` instructs the load balancer to resolve the `www` replica domain names under the *k3s.intranet.local& FQDN. The `value number 3` refers to the number of replicas and their associated domain names.
``` 
backend hello-world
      balance roundrobin
      server-template www 3 k3s.intranet.local:80 check
```

Furthermore, *k3s.intranet.local* is added to the HAProxy's `/etc/hosts` file to enable the resolution of any of the pod's `www` endpoint IPs. This ensures that the load balancer can perform round-robin distribution across the replicas
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-hosts
data:
  hosts: |
    10.42.1.55 k3s.intranet.local
```

## How is this not inconvenient?
In a way, it can be, as you either need to delay the deployment of HAProxy or delete and redeploy it after having edited the `haproxy.cfg ConfigMap`. On the positive side, it saves quite a bit of time by eliminating the need to manually declare each replica in `haproxy.cfg`. While this might not seem like a significant effort for just three replicas, it becomes increasingly valuable as the number of replicas grows, saving time and effort compared to manually managing them one by one. Additionally, this approach eases the deployment process by bypassing the need for an elaborate DNS server setup, making it ideal for rapidly deploying projects.

## Is there a better less cumbersome option?
Possibly, depending on your end goal. One alternative is to utilize a **Traefik** Ingress Controller. However, it's important to note that some form of DNS resolution setup is still required, assuming it is needed in the first place.
