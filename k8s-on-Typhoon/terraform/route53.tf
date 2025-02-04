resource "aws_route53_record" "some-application" {
  # DNS zone ID
  zone_id = var.dns_zone_id

  # DNS record
  name    = "app.${var.dns_zone}."
  type    = "CNAME"
  ttl     = 300
  records = ["${module.bruvio.ingress_dns_name}."]
}