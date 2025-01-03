NetworkPolicy Misconfigured
Fix the NetworkPolicy to allow communication

All Pods in Namespace default with label level=100x should be able to communicate with Pods with label level=100x in Namespaces level-1000 , level-1001 and level-1002 .

Fix the existing NetworkPolicy np-100x to ensure this.

Tip 1

For learning you can check the NetworkPolicy Editor

Tip 2

kubectl get pod -A --show-labels

# there are tester pods that you can use
kubectl get svc,pod -A --show-labels | grep tester


Solution


We need to update the NetworkPolicy to fix a mistake:

kubectl edit networkpolicy np-100x


apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-100x
  namespace: default
spec:
  podSelector:
    matchLabels:
      level: 100x
  policyTypes:
  - Egress
  egress:
  - to:
     - namespaceSelector:
        matchLabels:
         kubernetes.io/metadata.name: level-1000
       podSelector:
         matchLabels:
           level: 100x
  - to:
     - namespaceSelector:
        matchLabels:
         kubernetes.io/metadata.name: level-1001 # CHANGE
       podSelector:
         matchLabels:
           level: 100x
  - to:
     - namespaceSelector:
        matchLabels:
         kubernetes.io/metadata.name: level-1002
       podSelector:
         matchLabels:
           level: 100x
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP


Verify


These should work:

kubectl exec tester-0 -- curl tester.level-1000.svc.cluster.local
kubectl exec tester-0 -- curl tester.level-1001.svc.cluster.local
kubectl exec tester-0 -- curl tester.level-1002.svc.cluster.local


    Exam Desktop
    Editor
    Tab 1
    +

48 min

