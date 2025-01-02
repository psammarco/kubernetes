Application Misconfigured 2
Pods are not running, find the error and fix it

A Deployment has been imported from another Kubernetes cluster. But it's seems like the Pods are not running. Fix the Deployment so that it would work in any Kubernetes cluster.

Tip 1

k get pod # Pods are pending...


Tip 2

Check if there is a specific node name set for the Deployment, if so remove it.

Solution

It looks like a specific node name was set, remove it:

k edit deploy management-frontend 


apiVersion: apps/v1
kind: Deployment
metadata:
...
  name: management-frontend
...
spec:
...
  template:
...
    spec:
      containers:
      - image: nginx:alpine
        imagePullPolicy: IfNotPresent
        name: nginx
...
      dnsPolicy: ClusterFirst
      nodeName: staging-node1 # REMOVE


After waiting a bit we should see all replicas being ready:

k get pod # Pods getting ready

