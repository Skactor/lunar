# audit_aws_rec_ec2
#
# Ensure that all your Amazon Machine Images (AMIs) are using suitable naming
# conventions for tagging in order to manage them more efficiently and adhere
# to AWS resource tagging best practices. A naming convention is a well-defined
# set of rules useful for choosing the name of an AWS resource.
#
# Refer to:
# https://www.cloudconformity.com/conformity-rules/EC2/ami-naming-conventions.html
#.

audit_aws_rec_ec2 () {
  total=`expr $total + 1`
  images=`aws ec2 describe-images --region $aws_region --owners self --query "Images[].ImageId" --output text`
  for image in $images; do
	  name=`aws ec2 describe-images --region $aws_region --owners self --image-id ami-987843fb --query "Images[].Tags[?Key=='Name'].Value" --output text`
    if [ ! "$name" ]; then
      insecure=`expr $insecure + 1`
      echo "Warning:   AWS AMI $image does not have a Name tag [$insecure Warnings]"
      funct_verbose_message "" fix
      funct_verbose_message "aws ec2 create-tags --region $aws_region --resources $image --tags Key=Name,Value=<valid_name_tag>" fix
      funct_verbose_message "" fix
    else
      check=`echo $name |grep "$valid_host_grep"`
      if [ "$check" ]; then
        secure=`expr $secure + 1`
        echo "Secure:    AWS AMI $image has a valid Name tag [$secure Passes]"
      else
        insecure=`expr $insecure + 1`
        echo "Warning:   AWS AMI $image does not have a valid Name tag [$insecure Warnings]"
      fi
    fi
  done
}
