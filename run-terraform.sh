#!/bin/bash

TMP_FILE=/tmp/run-terraform.tmp.$$

source ./params.sh

# sed -i has extra param in OSX
SEDBAK=""

UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac
                SEDBAK=".bak"
                ;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${UNAME_OUT}"
esac
echo OS is ${MACHINE}


# Subsitute terraform variables to generate terraform/terraform.tfvars
#
echo ">>> Generating Terraform terraform.tfvars file from terraform.tfvars.template.."

cp terraform/terraform.tfvars.template terraform/terraform.tfvars

# Subsitiute tokens "##TOKEN_NAME##"
sed -i $SEDBAK "s/##TF_AWS_ACCESS_KEY##/$TF_AWS_ACCESS_KEY/" terraform/terraform.tfvars
sed -i $SEDBAK "s/##TF_AWS_SECRET_KEY##/$TF_AWS_SECRET_KEY/" terraform/terraform.tfvars
sed -i $SEDBAK "s/##TF_AWS_KEY_NAME##/$TF_AWS_KEY_NAME/"     terraform/terraform.tfvars


# Subsitute terraform variables to generate terraform/variables.tf
#
echo ">>> Generating Terraform variables.tf file from variables.template.."

cp terraform/variables.tf.template terraform/variables.tf

# Subsitiute tokens "##TOKEN_NAME##"
sed -i $SEDBAK "s/##TF_AWS_INSTANCE_PREFIX##/$TF_AWS_INSTANCE_PREFIX/" terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_DOMAINNAME##/$TF_AWS_DOMAINNAME/" terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_ROUTE53_ZONE_ID##/$TF_AWS_ROUTE53_ZONE_ID/" terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_REGION##/$TF_AWS_REGION/" terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_AVAILABILITY_ZONES##/$TF_AWS_AVAILABILITY_ZONES/" terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_AMI##/$TF_AWS_AMI/" terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_DOCKER_VOLUME_SIZE##/$TF_AWS_DOCKER_VOLUME_SIZE/" terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_MANAGER_COUNT##/$TF_AWS_MANAGER_COUNT/" terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_WORKER_COUNT##/$TF_AWS_WORKER_COUNT/" terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_MANAGER_INSTANCE_TYPE##/$TF_AWS_MANAGER_INSTANCE_TYPE/" terraform/variables.tf
sed -i $SEDBAK "s/##TF_AWS_WORKER_INSTANCE_TYPE##/$TF_AWS_WORKER_INSTANCE_TYPE/" terraform/variables.tf


#######################################################################
# Run the terraform deployment..
#
echo ">>> Applying Terraform in subdirectory ./terraform.."

CWD=`pwd`
cd ./terraform

# Run the Terraform apply
echo
/usr/local/bin/terraform apply
echo ">>> done."
#
#######################################################################


# Collect output variables
echo
echo ">>> Collecting variables from terraform output.."
/usr/local/bin/terraform output > $TMP_FILE
cd $CWD

# Some parsing into shell variables and arrays
DATA=`cat $TMP_FILE |sed "s/'//g"|sed 's/\ =\ /=/g'`
DATA2=`echo $DATA |sed 's/\ *\[/\[/g'|sed 's/\[\ */\[/g'|sed 's/\ *\]/\]/g'|sed 's/\,\ */\,/g'`

for var in `echo $DATA2`
do
  var_name=`echo $var | awk -F"=" '{print $1}'`
  var_value=`echo $var | awk -F"=" '{print $2}'|sed 's/\]//g'|sed 's/\[//g'`

#  echo LINE:$var_name: $var_value

  case $var_name in
    "region")
      REGION="$var_value"
      ;;
    "domain_name")
      DOMAIN_NAME="$var_value"
      ;;

    # Managers:
    "manager-primary-public-name")
      MANAGER_PRIMARY_PUBLIC_NAME=$var_value
      ;;
    "manager-primary-public-ip")
      MANAGER_PRIMARY_PUBLIC_IP=$var_value
      ;;
    "route53-managers")
      MANAGERS=$var_value
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MANAGER_NAME[$COUNT]=$entry
      done
      NUM_MANAGERS=$COUNT
      ;;
    "managers-public-names")
      MANAGERS_PUBLIC_NAMES="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MANAGER_PUBLIC_NAME[$COUNT]=$entry
      done
      ;;
    "managers-public-ips")
      MANAGERS_PUBLIC_IPS="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        MANAGER_PUBLIC_IP[$COUNT]=$entry
      done
      ;;

    # workers:
    "route53-workers")
      WORKERS="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        WORKER_NAME[$COUNT]=$entry
      done
      NUM_WORKERS=$COUNT
      ;;
    "workers-public-names")
      WORKERS_PUBLIC_NAMES="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        WORKER_PUBLIC_NAME[$COUNT]=$entry
      done
      ;;
    "workers-public-ips")
      WORKERS_PUBLIC_IPS="$var_value"
      COUNT=0
      for entry in $(echo $var_value |sed "s/,/ /g")
      do
        COUNT=$(($COUNT+1))
        WORKER_PUBLIC_IP[$COUNT]=$entry
      done
      ;;
  esac
done

echo ">>> done."


# Output shell variables
echo
echo ">>> Variables from Terraform output are:"
echo REGION=$REGION
echo DOMAIN_NAME=$DOMAIN_NAME

echo MANAGER_PRIMARY_PUBLIC_NAME=$MANAGER_PRIMARY_PUBLIC_NAME
echo MANAGER_PRIMARY_PUBLIC_IP=$MANAGER_PRIMARY_PUBLIC_IP

echo NUM_MANAGERS=$NUM_MANAGERS
for (( COUNT=1; COUNT<=$NUM_MANAGERS; COUNT++ ))
do
  echo MANAGER_NAME[$COUNT]=${MANAGER_NAME[$COUNT]}
  echo MANAGER_PUBLIC_NAME[$COUNT]=${MANAGER_PUBLIC_NAME[$COUNT]}
  echo MANAGER_PUBLIC_IP[$COUNT]=${MANAGER_PUBLIC_IP[$COUNT]}
done

echo NUM_WORKERS=$NUM_WORKERS
for (( COUNT=1; COUNT<=$NUM_WORKERS; COUNT++ ))
do
  echo WORKER_NAME[$COUNT]=${WORKER_NAME[$COUNT]}
  echo WORKER_PUBLIC_NAME[$COUNT]=${WORKER_PUBLIC_NAME[$COUNT]}
  echo WORKER_PUBLIC_IP[$COUNT]=${WORKER_PUBLIC_IP[$COUNT]}
done

echo ">>> done."


# Parse Ansible hosts.template to generate the Ansible hosts file
#
echo
echo ">>> Generating Ansible hosts file from hosts.template.."
cp ./hosts.template hosts

# Subsitiute tokens "##TOKEN_NAME##"
sed -i $SEDBAK "s/##DOMAIN_NAME##/$DOMAIN_NAME/" ./hosts
sed -i $SEDBAK "s/##REGION##/$REGION/" ./hosts
for (( COUNT=1; COUNT<=$NUM_MANAGERS; COUNT++ ))
do
  sed -i $SEDBAK "s/##MANAGER_NAME_${COUNT}##/${MANAGER_NAME[$COUNT]}/" ./hosts
  sed -i $SEDBAK "s/##MANAGER_PUBLIC_IP_${COUNT}##/${MANAGER_PUBLIC_IP[$COUNT]}/" ./hosts
done

# Append variable number of worker nodes to ansible hosts file
echo "" >> ./hosts
echo "[workers]" >> ./hosts
for (( COUNT=1; COUNT<=$NUM_WORKERS; COUNT++ ))
do
  echo "worker${COUNT} ansible_host=${WORKER_PUBLIC_IP[$COUNT]} fqdn=${WORKER_NAME[$COUNT]}" >> ./hosts
done
echo "" >> ./hosts

# From params.sh
#   ansible access:
sed -i $SEDBAK "s/##ANSIBLE_USER##/$ANSIBLE_USER/" ./hosts
_ANSIBLE_SSH_PRIVATE_KEY_FILE=$(echo $ANSIBLE_SSH_PRIVATE_KEY_FILE | sed 's/\//\\\//g')
sed -i $SEDBAK "s/##ANSIBLE_SSH_PRIVATE_KEY_FILE##/$_ANSIBLE_SSH_PRIVATE_KEY_FILE/" ./hosts
#   decision variables:
sed -i $SEDBAK "s/##FIREWALL_ENABLED##/$FIREWALL_ENABLED/" ./hosts
sed -i $SEDBAK "s/##FIREWALL_TYPE##/$FIREWALL_TYPE/" ./hosts
sed -i $SEDBAK "s/##DOCKER_STORAGE_DRIVER##/$DOCKER_STORAGE_DRIVER/" ./hosts
#   docker config:
_DOCKER_STORAGE_DEVICE=$(echo $DOCKER_STORAGE_DEVICE | sed 's/\//\\\//g')
sed -i $SEDBAK "s/##DOCKER_STORAGE_DEVICE##/$_DOCKER_STORAGE_DEVICE/" ./hosts
_DOCKER_EE_URL=$(echo $DOCKER_EE_URL | sed 's/\//\\\//g')
sed -i $SEDBAK "s/##DOCKER_EE_URL##/$_DOCKER_EE_URL/" ./hosts
sed -i $SEDBAK "s/##DOCKER_EE_RELEASE##/$DOCKER_EE_RELEASE/" ./hosts
sed -i $SEDBAK "s/##DOCKER_OS_VERSION##/$DOCKER_OS_VERSION/" ./hosts
echo ">>> done."


echo
echo ">>> Loop through hosts to accept keys before running Ansible playbook.."
MANAGERS=`for (( i=1; i<=$NUM_MANAGERS; i++ )) ; do echo ${MANAGER_NAME[$i]} ; done`
WORKERS=`for (( i=1; i<=$NUM_WORKERS; i++ )) ; do echo ${WORKER_NAME[$i]} ; done`
HOSTS="$MANAGERS $WORKERS"
for host in $HOSTS ;  do echo "Connecting to host: ${host}..." ; ssh-keyscan -H $host >> ~/.ssh/known_hosts ; done
echo ">>> Loop through hosts to accept keys before running Ansible playbook (CTRL-D to disconnect from each host in loop).."
for host in $HOSTS ;  do echo "Connecting to host: ${host}..." ; ssh -i $ANSIBLE_SSH_PRIVATE_KEY_FILE $ANSIBLE_USER@$host ; done
echo ">>> done."


# Don't run the ansible automatically, prompt with command:
#
echo 
echo "################################################################"
echo ">>> Please check the Ansible hosts file and run the playbook <<<"
echo ">>>                                                          <<<"
echo ">>>    ansible-playbook -i hosts -s site.yml                 <<<"
echo ">>>                                                          <<<"
echo "################################################################"
echo


/bin/rm $TMP_FILE
exit 0

