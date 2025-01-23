Scheduling Pod Affinity
Select Node by Pod Affinity

There is a Pod YAML provided at /root/hobby.yaml .

That Pod should be preferred to be only scheduled on Nodes where Pods with label level=restricted are running.

For the topologyKey use kubernetes.io/hostname .

There are no taints on any Nodes which means no tolerations are needed.

Tip 1

https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node

Look for Inter-pod affinity and anti-affinity

Tip 2

There is one Pod with label level=restrict running on Node node01 :

kubectl get pod --show-labels


Tip 3

We need to implement a solution using preferredDuringSchedulingIgnoredDuringExecution :

spec:
  affinity:
    podAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:


Solution

Extend the provided YAML at /root/hobby.yaml :

apiVersion: v1
kind: Pod
metadata:
  labels:
    level: hobby
  name: hobby-project
spec:
  containers:
  - image: nginx:alpine
    name: c
  affinity:
    podAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: level
              operator: In
              values:
              - restricted
          topologyKey: kubernetes.io/hostname


Another way to solve the same requirement would be:

...
  affinity:
    podAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              level: restricted
          topologyKey: kubernetes.io/hostname


Then create the Pod.

We should see the Pod hobby-project is scheduled on the node01 one, because Pod restricted is also on node01 :

kubectl get pod -owide --show-labels



