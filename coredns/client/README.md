## Deploy dnstools replica pods
- Replace the IP value from *"nameservers dnsConfig"* section in dnsmax.yaml with the *"Service ClusterIP"* address;
```
spec:
      dnsPolicy: "None"
      dnsConfig:
        nameservers:
        - 10.43.229.169 
```
kubectl apply -f client/dnsmax.yaml
