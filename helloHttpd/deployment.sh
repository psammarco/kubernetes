#!/bin/bash
set -e

## Print an error message and exit should any of the tasks fail
print_error() {
    echo "Error: $1" >&2
    exit 1
}

## Deploy the nginx application
echo "- Deploying the nginx application"
kubectl apply -f www || print_error "Failed to deploy nginx application"
sleep 10

## Replace old HAProxy server IP with new one
# Note, for this to work the first octet of the old IP 
# in haproxy-hosts-configmap.yaml has to be '10' and ends with port '80'. 
# If you have/expect anything different, edit the string below accordingly.
echo -e "\n- Replacing old HAProxy server IP with new one"
BALANCER_IP=$(sudo kubectl get endpoints www | tail -1 | awk -F',' '{print $2}')
sed -i "s/10[^ ]*80/${BALANCER_IP}/g" HAProxy/haproxy-hosts-configmap.yaml || print_error "Failed to replace HAProxy server IP"

## Deploy HAProxy application
echo -e "\n- Deploying HAProxy application"
kubectl apply -f HAProxy || print_error "Failed to deploy HAProxy application"

echo "Deployment completed successfully"
# To add a verification step using curl.
# One way this can be achieved is by using the BALANCER_IP variable without ':80' and replace it in /etc/hosts. Though you need to be careful you don't accidentally replace other entries as well.
