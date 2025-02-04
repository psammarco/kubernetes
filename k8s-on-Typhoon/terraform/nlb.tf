# # Forward TCP traffic to a target group
# resource "aws_lb_listener" "some-app" {
#   load_balancer_arn = module.bruvio.nlb_id
#   protocol          = "TCP"
#   port              = "30333"  # Listen on the same port as NodePort

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.some-app.arn
#   }
# }


# # Target group of workers for some-app
# resource "aws_lb_target_group" "some-app" {
#   name        = "some-app"
#   vpc_id      = module.bruvio.vpc_id
#   target_type = "instance"

#   protocol = "TCP"
#   port     = 30333  # Forward traffic to NodePort on Kubernetes nodes

#   health_check {
#     protocol = "TCP"
#     port     = 30333  # Health check on the NodePort
#   }
# }

# resource "aws_security_group_rule" "allow_nlb_to_nodeport" {
#   security_group_id = module.bruvio.worker_security_groups[0]

#   type        = "ingress"
#   protocol    = "tcp"
#   from_port   = 30333
#   to_port     = 30333
#   cidr_blocks = ["0.0.0.0/0"]
# }
