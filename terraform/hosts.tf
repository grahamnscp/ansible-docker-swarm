# Host Instances:

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}


# UCP Manager Instances:
#
resource "aws_instance" "manager" {
  ami           = "${var.aws_ami}"
  instance_type = "${var.manager_instance_type}"
  key_name      = "${var.key_name}"

  root_block_device {
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Second disk for docker storage
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "${var.docker_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  count = "${var.manager_count}"

  security_groups = [ "${aws_security_group.ddc.name}" ]
  availability_zone = "${element(split(",", var.availability_zones), count.index) }"

  tags {
    Name = "${var.name_prefix}_manager${count.index + 1}"
  }
}


# UCP Worker Instances:
#
# Linux Workers:
#
resource "aws_instance" "worker" {
  ami           = "${var.aws_ami}"
  instance_type = "${var.worker_instance_type}"
  key_name      = "${var.key_name}"

  root_block_device {
    volume_type = "gp2"
    delete_on_termination = true
  }

  # Second disk for docker storage
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "${var.docker_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  count = "${var.worker_count}"

  security_groups = [ "${aws_security_group.ddc.name}" ]
  availability_zone = "${element(split(",", var.availability_zones), count.index) }"

  tags {
    Name = "${var.name_prefix}_worker${count.index + 1}"
  }
}


