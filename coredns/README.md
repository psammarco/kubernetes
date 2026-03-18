### CoreDNS deployment
This CoreDNS configuration serves as the primary DNS server for your network or cluster. It efficiently handles both internal pod-to-pod resolution and external DNS requests. Specifically, it forwards public DNS queries to Google DNS servers while seamlessly managing internal pod resolution within your cluster.

## Installation
```
helm repo add coredns https://coredns.github.io/helm
helm install coredns coredns/coredns -n coredns -f helm/values.yaml --create-namespace
```

## Quick breakdown
- Handles queries for the "intranet.local" subdomain;
- Pods must be part of a Service in order for local DNS resolution to work between pods;

**endpoint_pod_names** in your Corefile allows for intra pods resolution as follow:
```
<pod-name>.<subdomain>.<namespace>.svc.<zone>
```

## Notes
In a production environment, it's recommended to deploy CoreDNS in a dedicated namespace, implement TLS certificates for secure communication, and consider running multiple replicas for high availability. Additionally, CoreDNS can serve as a secondary DNS server exclusively for Kubernetes, provided you already have an existing upstream DNS server.
