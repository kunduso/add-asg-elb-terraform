[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-white.svg)](https://choosealicense.com/licenses/unlicense/) [![GitHub pull-requests closed](https://img.shields.io/github/issues-pr-closed/kunduso/add-asg-elb-terraform)](https://github.com/kunduso/add-asg-elb-terraform/pulls?q=is%3Apr+is%3Aclosed) [![GitHub pull-requests](https://img.shields.io/github/issues-pr/kunduso/add-asg-elb-terraform)](https://GitHub.com/kunduso/add-asg-elb-terraform/pull/) 
[![GitHub issues-closed](https://img.shields.io/github/issues-closed/kunduso/add-asg-elb-terraform)](https://github.com/kunduso/add-asg-elb-terraform/issues?q=is%3Aissue+is%3Aclosed) [![GitHub issues](https://img.shields.io/github/issues/kunduso/add-asg-elb-terraform)](https://GitHub.com/kunduso/add-asg-elb-terraform/issues/) 
[![terraform-infra-provisioning](https://github.com/kunduso/add-asg-elb-terraform/actions/workflows/terraform.yml/badge.svg?branch=main)](https://github.com/kunduso/add-asg-elb-terraform/actions/workflows/terraform.yml) [![checkov-static-analysis-scan](https://github.com/kunduso/add-asg-elb-terraform/actions/workflows/code-scan.yml/badge.svg?branch=main)](https://github.com/kunduso/add-asg-elb-terraform/actions/workflows/code-scan.yml)
![Image](https://skdevops.files.wordpress.com/2023/09/82-image-0.png)
## Motivation
I aimed to create an Amazon Auto Scaling group and launch template consisting EC2 instances hosted in three different availability zones in three separate *private* subnets in a region. Then, attach the Amazon EC2 instances to a target group of an application load balancer in the public subnet using **Terraform and GitHub Actions.**

<br />I discussed the concept in detail in my notes at -[create Amazon EC2 Auto Scaling group and load balancer using Terraform and GitHub Actions.](https://skundunotes.com/2023/09/12/create-amazon-ec2-auto-scaling-group-and-load-balancer-using-terraform-and-github-actions/)

<br />If you are interested in learning about the CPU based scaling policies check out this note:  [create an Amazon EC2 Auto Scaling group with metric scaling policies using Terraform.](https://skundunotes.com/2023/09/27/create-an-amazon-ec2-auto-scaling-group-with-metric-scaling-policies-using-terraform/)

<br />To learn how to trigger an `instance refresh` with a `launch_template` update, head over to this note: [trigger instance refresh of Amazon EC2 Auto Scaling group with a launch template update using Terraform](http://skundunotes.com/2023/10/05/trigger-instance-refresh-of-amazon-ec2-auto-scaling-group-with-a-launch-template-update-using-terraform/)

<br />I also used [Infracost](https://www.infracost.io/) to generate a cost estimate for building the architecture. Checkout the cool *monthly cost badge* at the top of this file. To learn more about adding Infracost estimates to your repository, head over to this note -[estimate AWS Cloud resource cost with Infracost, Terraform, and GitHub Actions.](https://skundunotes.com/2023/07/17/estimate-aws-cloud-resource-cost-with-infracost-terraform-and-github-actions/)
<br />Lastly, I also automated the resource provision process using the GitHub Actions pipeline. I discussed that in detail at -[CI-CD with Terraform and GitHub Actions to deploy to AWS.](https://skundunotes.com/2023/03/07/ci-cd-with-terraform-and-github-actions-to-deploy-to-aws/)
## Prerequisites
For this code to function without errors, I created an OpenID Connect identity provider in Amazon Identity and Access Management that has a trust relationship with this GitHub repository. You can read about it [here](https://skundunotes.com/2023/02/28/securely-integrate-aws-credentials-with-github-actions-using-openid-connect/) to get a detailed explanation with steps.
<br />I stored the `ARN` of the `IAM Role` as a GitHub secret which is referred to in the [`terraform.yml`](https://github.com/kunduso/add-asg-elb-terraform/blob/de8f1559fdc19e8decf5066e383537511f512244/.github/workflows/terraform.yml#L39-L44) file.
<br />Since I used Infracost in this repository, I stored the `INFRACOST_API_KEY` as a repository secret. It is referenced in the [`terraform.yml`](https://github.com/kunduso/add-asg-elb-terraform/blob/de8f1559fdc19e8decf5066e383537511f512244/.github/workflows/terraform.yml#L52) GitHub actions workflow file.
<br />As part of the Infracost integration, I also created an `INFRACOST_API_KEY` and stored that as a GitHub Actions secret. I also managed the cost estimate process using a GitHub Actions variable `INFRACOST_SCAN_TYPE` where the value is either `hcl_code` or `tf_plan`, depending on the type of scan desired.
## Usage
Ensure that the policy attached to the IAM role whose credentials are being used in this configuration has permission to create and manage all the resources that are included in this repository.
<br />
<br />Review the code, including the [`terraform.yml`](./.github/workflows/terraform.yml) to understand the steps in the GitHub Actions pipeline. Also, review the `terraform` code to understand all the concepts associated with creating an AWS Auto Scaling group.
<br />To check the pipeline logs, click on the **Build Badge** (terrform-infra-provisioning) above the image in this ReadMe.
## Contributing
If you find any issues or have suggestions for improvement, feel free to open an issue or submit a pull request. Contributions are always welcome!
## License
This code is released under the Unlincse License. See [LICENSE](LICENSE).