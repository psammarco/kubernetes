# Kubernetes Cluster Deployment with Terraform

This repository is to track my progresso to achieve [CKA cerficication](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/) 

## Overview

This project automates the deployment of a Kubernetes cluster using Terraform. 
It also contains manifest and documentation to support learning Kubernetes.

## HOW

There are 3 active branches using different approaches

### Master

branch **master** uses an approach from scratch, provisoning ec2 instances and installing kubernetes, for now useful for local testing.

#### Features

- **Automated Deployment:** The infrastructure is defined using Terraform, making it easy to provision and manage.
- **Kubernetes Setup:** The EC2 instances are configured using `user-data` scripts to install Kubernetes and initialize the cluster automatically.

### feature/EKS

deployes a kubernetes cluster using AWS EKS

### feature/Typhoon

deployes a Kubernetes cluster using Typhoon




## Course Reference

This work follows the concepts and best practices from the [Kubernetes Fundamentals (LFS258)](https://trainingportal.linuxfoundation.org/courses/kubernetes-fundamentals-lfs258) course by the Linux Foundation.



