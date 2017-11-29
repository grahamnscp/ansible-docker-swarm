#
# These variables are subsituted into templates buy run-terraform.sh
#

# Terraform Variables:
#
# - terraform/variables.tf.template -> terraform/variables.tf
#
TF_AWS_INSTANCE_PREFIX=my
TF_AWS_DOMAINNAME=my.existing.com
#
TF_AWS_ROUTE53_ZONE_ID=AAAAAAAAAAAAA
#
TF_AWS_REGION=eu-west-2
TF_AWS_AVAILABILITY_ZONES=eu-west-2a,eu-west-2b
TF_AWS_AVAILABILITY_ZONES_WIN=eu-west-2a
#
# RHEL 7.4
TF_AWS_AMI=ami-a1f5e4c5
#
TF_AWS_DOCKER_VOLUME_SIZE=31
TF_AWS_MANAGER_COUNT=3
TF_AWS_WORKER_COUNT=2
#
TF_AWS_MANAGER_INSTANCE_TYPE=t2.large
TF_AWS_WORKER_INSTANCE_TYPE=t2.large


# - terraform/terraform.tfvars.template -> terraform/terraform.tfvars
#
TF_AWS_ACCESS_KEY=AAAAAAAAAAAAAAAAAAAA
TF_AWS_SECRET_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
TF_AWS_KEY_NAME=myawskey


# Ansible Variables:
#
# - hosts.template -> hosts
#
ANSIBLE_USER=ec2-user 
ANSIBLE_SSH_PRIVATE_KEY_FILE=~/.ssh/myawskey.pem
#
FIREWALL_ENABLED=true
# values: iptables or firewalld
FIREWALL_TYPE=iptables
# values: overlay2 or devicemapper
DOCKER_STORAGE_DRIVER=overlay2
#
DOCKER_STORAGE_DEVICE=/dev/xvdb
#
# Engine Package:
DOCKER_EE_URL=https://storebits.docker.com/ee/rhel/sub-aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
DOCKER_OS_VERSION=7.4
DOCKER_EE_RELEASE=stable-17.06

