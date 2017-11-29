# Route53 DNS Entries:

#resource "aws_route53_zone" "ddc" {
#  name = "${var.domainname}"
#  comment = "${var.name_prefix} DDC zone"
#}

#resource "aws_route53_record" "ddc-ns" {
#    zone_id = "${aws_route53_zone.ddc.zone_id}"
#    name = "${var.domainname}"
#    type = "NS"
#    ttl = "30"
#    records = [
#        "${aws_route53_zone.ddc.name_servers.0}",
#        "${aws_route53_zone.ddc.name_servers.1}",
#        "${aws_route53_zone.ddc.name_servers.2}",
#        "${aws_route53_zone.ddc.name_servers.3}"
#    ]
#}

resource "aws_route53_record" "manager" {
  count = "${var.manager_count}"
#  zone_id = "${aws_route53_zone.ddc.zone_id}"
  zone_id = "${var.route53_zone_id}"
  name = "manager${count.index + 1}.${var.domainname}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.manager.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "worker" {
  count = "${var.worker_count}"
#  zone_id = "${aws_route53_zone.ddc.zone_id}"
  zone_id = "${var.route53_zone_id}"
  name = "worker${count.index + 1}.${var.domainname}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.worker.*.public_ip, count.index)}"]
}

