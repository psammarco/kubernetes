### CoreDNS deployment
This CoreDNS configuration serves as the primary DNS server for your network or cluster. It efficiently handles both internal pod-to-pod resolution and external DNS requests. Specifically, it forwards public DNS queries to Google DNS servers while seamlessly managing internal pod resolution within your cluster.

## Installation
```
helm repo add coredns https://coredns.github.io/helm

# If your cluster already ships with its own CoreDNS deployment, the ConfigMap already exists but isn't Helm-managed. You need to label/annotate it before Helm can adopt it.
for resource in deployment/coredns service/kube-dns serviceaccount/coredns clusterrole/system:coredns clusterrolebinding/system:coredns; do
  kubectl label $resource -n kube-system app.kubernetes.io/managed-by=Helm --overwrite 2>/dev/null || \
  kubectl label $resource app.kubernetes.io/managed-by=Helm --overwrite 2>/dev/null
  kubectl annotate $resource -n kube-system \
    meta.helm.sh/release-name=coredns \
    meta.helm.sh/release-namespace=kube-system --overwrite 2>/dev/null || \
  kubectl annotate $resource \
    meta.helm.sh/release-name=coredns \
    meta.helm.sh/release-namespace=kube-system --overwrite 2>/dev/null
done


helm install -f helm/values.yaml coredns coredns/coredns -n kube-system
```

## Quick breakdown
- Handles queries for the "intranet.local" subdomain;
- Pods must be part of a Service in order for local DNS resolution to work between pods;

**endpoint_pod_names** in your Corefile allows for intra pods resolution as follow:
```
podname.servicename.namespacename.svc.intranet.local
```

## Notes
In a production environment, it's recommended to deploy CoreDNS in a dedicated namespace, implement TLS certificates for secure communication, and consider running multiple replicas for high availability. Additionally, CoreDNS can serve as a secondary DNS server exclusively for Kubernetes, provided you already have an existing upstream DNS server.
