# Learn Terraform - Provision an EKS Cluster

This repo is a companion repo to the [Provision an EKS Cluster tutorial](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks), containing
Terraform configuration files to provision an EKS cluster on AWS.

Set the TF_CLOUD_ORGANIZATION environment variable to your HCP Terraform organization name. This will configure your HCP Terraform integration.
```
$ export TF_CLOUD_ORGANIZATION=
```

Run the following command to retrieve the access credentials for your cluster and configure kubectl.
```
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
```
