Ingress Create
Create Services for existing Deployments

There are two existing Deployments in Namespace world which should be made accessible via an Ingress.

First: create ClusterIP Services for both Deployments for port 80 . The Services should have the same name as the Deployments.

Tip

k expose deploy -h


Solution

k -n world expose deploy europe --port 80
k -n world expose deploy asia --port 80

Ingress Create
Create Ingress for existing Services

The Nginx Ingress Controller has been installed.

Create a new Ingress resource called world for domain name world.universe.mine . The domain points to the K8s Node IP via /etc/hosts .

The Ingress resource should have two routes pointing to the existing Services:

http://world.universe.mine:30080/europe/

and

http://world.universe.mine:30080/asia/


Explanation

Check the NodePort Service for the Nginx Ingress Controller to see the ports

k -n ingress-nginx get svc ingress-nginx-controller


We can reach the NodePort Service via the K8s Node IP:

curl http://172.30.1.2:30080


And because of the entry in /etc/hosts we can call

curl http://world.universe.mine:30080


Tip 1

The Ingress resources needs to be created in the same Namespace as the applications.

Tip 2

Find out the ingressClassName with:

k get ingressclass


Tip 3

You can work with this template

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: world
  namespace: world
  annotations:
    # this annotation removes the need for a trailing slash when calling urls
    # but it is not necessary for solving this scenario
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx # k get ingressclass
  rules:
  - host: "world.universe.mine"
  ...


Solution


apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: world
  namespace: world
  annotations:
    # this annotation removes the need for a trailing slash when calling urls
    # but it is not necessary for solving this scenario
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx # k get ingressclass
  rules:
  - host: "world.universe.mine"
    http:
      paths:
      - path: /europe
        pathType: Prefix
        backend:
          service:
            name: europe
            port:
              number: 80
      - path: /asia
        pathType: Prefix
        backend:
          service:
            name: asia
            port:
              number: 80

