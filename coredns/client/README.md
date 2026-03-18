## Testing dnstools StatefulSet application
- Simply deploy it using kubectl:
```
kubectl apply -f client/client.yaml
```
# Test intra-pod Domain Name resolution
```
pietro@kube-controller-001:~$ for host in dnsutils-0 dnsutils-1 dnsutils-2; do   for domain in cluster.local intranet.local; do     kubectl exec -it dnsutils-0 -n debug -- ping -c1 ${host}.pod.debug.svc.$domain;   done; done
PING dnsutils-0.pod.debug.svc.cluster.local (10.42.2.12): 56 data bytes
64 bytes from 10.42.2.12: seq=0 ttl=64 time=0.266 ms

--- dnsutils-0.pod.debug.svc.cluster.local ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.266/0.266/0.266 ms
PING dnsutils-0.pod.debug.svc.intranet.local (10.42.2.12): 56 data bytes
64 bytes from 10.42.2.12: seq=0 ttl=64 time=0.175 ms

--- dnsutils-0.pod.debug.svc.intranet.local ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.175/0.175/0.175 ms
PING dnsutils-1.pod.debug.svc.cluster.local (10.42.1.7): 56 data bytes
64 bytes from 10.42.1.7: seq=0 ttl=62 time=0.947 ms

--- dnsutils-1.pod.debug.svc.cluster.local ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.947/0.947/0.947 ms
PING dnsutils-1.pod.debug.svc.intranet.local (10.42.1.7): 56 data bytes
64 bytes from 10.42.1.7: seq=0 ttl=62 time=0.999 ms

--- dnsutils-1.pod.debug.svc.intranet.local ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.999/0.999/0.999 ms
PING dnsutils-2.pod.debug.svc.cluster.local (10.42.4.12): 56 data bytes
64 bytes from 10.42.4.12: seq=0 ttl=62 time=1.023 ms

--- dnsutils-2.pod.debug.svc.cluster.local ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 1.023/1.023/1.023 ms
PING dnsutils-2.pod.debug.svc.intranet.local (10.42.4.12): 56 data bytes
64 bytes from 10.42.4.12: seq=0 ttl=62 time=0.920 ms

--- dnsutils-2.pod.debug.svc.intranet.local ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.920/0.920/0.920 ms
pietro@kube-controller-001:~$
```
