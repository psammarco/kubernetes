ConfigMap Access in Pods
Access ConfigMaps in Pod

    Create a Pod named pod1 of image nginx:alpine
    Make key tree of ConfigMap trauerweide available as environment variable TREE1
    Mount all keys of ConfigMap birke as volume. The files should be available under /etc/birke/*
    Test env+volume access in the running Pod


Solution

apiVersion: v1
kind: Pod
metadata:
  name: pod1
spec:
  volumes:
  - name: birke
    configMap:
      name: birke
  containers:
  - image: nginx:alpine
    name: pod1
    volumeMounts:
      - name: birke
        mountPath: /etc/birke
    env:
      - name: TREE1
        valueFrom:
          configMapKeyRef:
            name: trauerweide
            key: tree


Verify

kubectl exec pod1 -- env | grep "TREE1=trauerweide"
kubectl exec pod1 -- cat /etc/birke/tree
kubectl exec pod1 -- cat /etc/birke/level
kubectl exec pod1 -- cat /etc/birke/department

