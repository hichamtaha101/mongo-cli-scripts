#!/usr/local/bin/bash

source ./variables/ssh_variables.sh

function ssh_ec2_usage() {
	echo "Usage: ${0}	[i:]

Connect to an AWS EC2 instance.

[-i instance]		Specify the instance you are connecting to.
             		(${!ssh_keys[@]})" >&2
	exit 1
}

#SSH into instances
ec2_instance=''

# Grab instance value.
# local OPTIND o a
while getopts i: OPTION
do
	case $OPTION in
		i)
		ec2_instance=$OPTARG
		;;

		*)
		ssh_ec2_usage
		;;
	esac
done

# Validate instance value.
if [[ -z $ec2_instance ]] || [[ ! ${!ssh_keys[@]} =~ $ec2_instance ]]; then
	ssh_ec2_usage
fi

#SSH into the instance.
ssh -i ./keys/${ssh_keys[$ec2_instance]} ${ssh_user[$ec2_instance]}@${ssh_address[$ec2_instance]}