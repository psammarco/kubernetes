## Testing dnstools replica deployment
- Replace the IP value from *"nameservers dnsConfig"* section in dnsmax.yaml with the **CoreDNS**  *"Service ClusterIP"*:
```
   spec:
      subdomain: dnsmax
      dnsPolicy: "None"
      dnsConfig:
        nameservers:
        - 10.43.141.15
```
- Then simply deploy it using kubectl:
```
kubectl apply -f client/dnsmax.yaml
```

### Test if it works *(replace dnsmax-99999-XXX with the actual pod name)*
```
kubectl exec -it dnsmax-99999-XX1 -n dnsmax -- /bin/sh
ping dnsmax-99999-XX2.dnsmax.dnsmax.svc.intranet.local
ping dnsmax-99999-XX2.dnsmax.dnsmax.svc.cluster.local
```
