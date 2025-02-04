
resource "aws_security_group" "control_plane_sg" {
  name        = "control-plane-sg"
  description = "Security group for the control plane"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "control-plane-sg"
  }
}

# investigate following security group settings following documentation

# resource "aws_security_group" "control_plane_sg" {
#   name        = "control-plane-sg"
#   description = "Security group for the control plane"

#   # SSH from your local machine (only your IP address is allowed)
#   ingress {
#     description = "Allow SSH from my local machine"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]

#   }

#   # API server accessible by anyone
#   ingress {
#     description = "Allow access to API server"
#     from_port   = 6443
#     to_port     = 6443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # etcd server client API accessible only within the private network
#   ingress {
#     description = "Allow etcd server client API on private network"
#     from_port   = 2379
#     to_port     = 2380
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]

#   }
#   ingress {
#     description = "Allow etcd server client API on private network"
#     from_port   = 8080
#     to_port     = 9000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]

#   }
#   # Kubelet, kube-scheduler, kube-controller on private network only
#   ingress {
#     description = "Allow kubelet, scheduler, and controller access on private network"
#     from_port   = 10250
#     to_port     = 10259
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]

#   }

#   # Egress rule to allow all outbound traffic to anywhere (IPv4)
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"] # Allows outbound traffic to anywhere over IPv4
#   }

# tags = {
#   Name = "control-plane-sg"
# }
# }