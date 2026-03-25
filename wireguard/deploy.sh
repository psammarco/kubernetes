#!/bin/bash
set -e

TIMEOUT=120

apply() {
  kubectl apply "$@"
}

rollout() {
  local kind=$1
  local name=$2
  echo "Waiting for $kind/$name..."
  if ! kubectl rollout status $kind/$name -n wireguard --timeout=${TIMEOUT}s; then
    echo "ERROR: $kind/$name failed to roll out"
    kubectl get pods -n wireguard
    exit 1
  fi
}

echo "=== Deploying WireGuard ==="

apply -f namespace.yaml
apply -f service.yaml
apply -f configmap.yaml
apply -f statefulset.yaml
rollout statefulset wireguard

apply -f loadBalancer/configmap.yaml
apply -f loadBalancer/deployment.yaml
apply -f loadBalancer/service.yaml
rollout deployment nginx-udp

echo "=== Deployment complete ==="
kubectl get all -n wireguard
