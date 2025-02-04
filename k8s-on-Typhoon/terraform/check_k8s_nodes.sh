#!/bin/bash

export KUBECONFIG=$1

# Function to check the status of all nodes
check_nodes_status() {
  # Get the status of all nodes
  node_status=$(kubectl get nodes 2>/dev/null | grep -v NAME | awk '{print $2}')

  # Check if no nodes are found
  if [ -z "$node_status" ]; then
    echo "No nodes found"
    return 1
  fi

  # Check if all nodes are in the "Ready" state
  all_ready=true
  for status in $node_status; do
    if [ "$status" != "Ready" ]; then
      all_ready=false
      break
    fi
  done

  if [ "$all_ready" = true ]; then
    return 0
  else
    return 1
  fi
}

# Loop until all nodes are ready
while true; do
  if check_nodes_status; then
    echo "All Kubernetes nodes are ready!"
    break
  else
    echo "Not all nodes are ready yet or no nodes found. Checking again in 10 seconds..."
    sleep 10
  fi
done
