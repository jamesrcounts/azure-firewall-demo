data "aws_route53_zone" "primary" {
  name = var.zone_name
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.name}.${var.zone_name}"
  type    = "A"
  ttl     = "300"
  records = [var.ip_address]
}