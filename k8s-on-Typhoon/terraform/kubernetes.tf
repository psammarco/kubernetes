module "bruvio" {
  source = "git::https://github.com/bruvio/typhoon//aws/flatcar-linux/kubernetes?ref=feature/enable-IMDSv2"



  cluster_name       = var.cluster_name
  dns_zone           = var.dns_zone
  dns_zone_id        = var.dns_zone_id
  ssh_authorized_key = var.ssh_authorized_key
  networking         = "calico"
  network_mtu        = 8981
  components         = local.custom_components
  # worker_target_groups = [
  #   aws_lb_target_group.some-app.id,
  # ]

  # optional
  host_cidr                   = "10.0.0.0/16"
  controller_count            = 1
  worker_count                = 2
  worker_node_labels          = ["worker"]
  http_tokens                 = "required"
  http_put_response_hop_limit = 1
}

resource "local_file" "kubeconfig-bruvio" {
  content  = module.bruvio.kubeconfig-admin
  filename = "${var.cluster_name}-config"
}



locals {
  custom_components = {
    enable = true
    coredns = {
      enable = true
    }
    kube_proxy = {
      enable = true
    }
    flannel = null
    calico = {
      enable = true
    }
    cilium = null
  }
}


resource "null_resource" "wait_for_nodes" {
  provisioner "local-exec" {
    command = "${abspath(path.module)}/check_k8s_nodes.sh ${abspath(path.module)}/${var.cluster_name}-config"
  }

  depends_on = [module.bruvio]
}



resource "null_resource" "apply_nginx_ingress" {
  provisioner "local-exec" {
    command = "kubectl apply -R -f ./addons/nginx-ingress/aws"
  }

  depends_on = [null_resource.wait_for_nodes]
}
