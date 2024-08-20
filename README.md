# Kubernetes Cluster Deployment with Terraform

This repository is a fork of [psammarco/kubernetes](https://github.com/psammarco/kubernetes).

## Overview

This project automates the deployment of a Kubernetes cluster using Terraform. The setup provisions three EC2 instances:

- **1 Master Node**
- **2 Worker Nodes**

## Features

- **Automated Deployment:** The infrastructure is defined using Terraform, making it easy to provision and manage.
- **Kubernetes Setup:** The EC2 instances are configured using `user-data` scripts to install Kubernetes and initialize the cluster automatically.

## Course Reference

This work follows the concepts and best practices from the [Kubernetes Fundamentals (LFS258)](https://trainingportal.linuxfoundation.org/courses/kubernetes-fundamentals-lfs258) course by the Linux Foundation.



