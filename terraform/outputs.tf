# Output Values:

output "region" {
  value = "${var.aws_region}"
}
output "domain_name" {
  value = "${var.domainname}"
}

output "manager-primary-public-name" {
  value = "${element(aws_instance.manager.*.public_dns,0)}"
}
output "manager-primary-public-ip" {
  value = "${element(aws_instance.manager.*.public_ip,0)}"
}

output "managers-public-names" {
  value = ["${aws_instance.manager.*.public_dns}"]
}
output "managers-public-ips" {
  value = ["${aws_instance.manager.*.public_ip}"]
}

output "workers-public-names" {
  value = ["${aws_instance.worker.*.public_dns}"]
}
output "workers-public-ips" {
  value = ["${aws_instance.worker.*.public_ip}"]
}

output "route53-managers" {
  value = ["${aws_route53_record.manager.*.name}"]
}
output "route53-workers" {
  value = ["${aws_route53_record.worker.*.name}"]
}

