#!/bin/bash
amazon-linux-extras install epel -y
yum update -y
yum install stress -y
yum install -y httpd.x86_64
yum install -y jq
REGION_AV_ZONE=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .availabilityZone -r`
systemctl start httpd.service
systemctl enable httpd.service
echo "Updated Message: Hello World from $(hostname -f) from the availability zone: $REGION_AV_ZONE" > /var/www/html/index.html