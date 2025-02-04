#!/bin/bash
set -e

unset BALANCER_IP
unset EXIT_STATUS

## Print an error message and exit should any of the tasks fail
print_error() {
    echo "Error: $1" >&2
    exit 1
}

## Deploy the nginx application
echo "** Deploying the nginx application"
kubectl apply -f www || print_error "Failed to deploy nginx application"
sleep 5

## Replace old HAProxy server IP with new one
# Note, for this to work the first octet of the old IP 
# in haproxy-hosts-configmap.yaml has to be '10' and ends with port '80'. 
# If you have/expect anything different, edit the string below accordingly.
echo -e "\n** Replacing old HAProxy server IP with new one"
BALANCER_IP=$(sudo kubectl get endpoints www | tail -1 | awk -F',' '{print $2}')
sed -i "s/10[^ ]*80/${BALANCER_IP}/g" HAProxy/haproxy-hosts-configmap.yaml || print_error "Failed to replace HAProxy server IP"

## Deploy HAProxy application
echo -e "\n** Deploying HAProxy application"
kubectl apply -f HAProxy || print_error "Failed to deploy HAProxy application"

## Update local hosts file with new HAProxy server IP
# using some regex shenanigans curtesy of ChatGPT :)
# MAKE A BACKUP OF /etc/hosts BEFORE UNCOMMENTING THIS!

#echo -e "\n** Updating domain name entry in /etc/hosts" 
#if grep -q "k3s\.intranet\.local" /etc/hosts; then
#    sed -i "s/^\([0-9.]\+\)[[:space:]]\+k3s\.intranet\.local/${BALANCER_IP%:*} k3s.intranet.local/" /etc/hosts
#else
#    echo "No 'k3s.intranet.local' entry found in /etc/hosts. Nothing to do!"
#    exit 0
#fi

## Query k3s.intranet.local to see if alive
#echo -e "\n** Checking deployment status" 
#curl -s -o /dev/null k3s.intranet.local

#EXIT_STATUS=$?
#if [ $EXIT_STATUS -eq 0 ]; then
#    echo "k3s.intranet.local is live. Deployment was successful.."
#else
#    echo "k3s.intranet.local is unreachable. Deployment was unsuccessful..."
#fi

