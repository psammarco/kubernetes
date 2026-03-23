#!/bin/bash
kubectl apply -f namespace.yaml -f service.yaml -f service-wg.yaml -f configmap.yaml -f statefulset.yaml -f loadBalancer/configmap.yaml -f loadBalancer/deployment.yaml -f loadBalancer/service.yaml
