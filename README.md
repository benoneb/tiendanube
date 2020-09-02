# TiendaNube Test

## Usage

To run this terraform you need to execute:

```bash
curl -L "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint.zip && unzip tflint.zip && sudo install tflint /usr/bin && tflint -v && rm tflint.zip && rm tflint
cd pre-provisioning
terraform fmt
terraform init
terraform validate
tflint --deep
terraform plan -out tfplan
terraform apply tfplan && \
cd ../provisioning
## Check if Terraform configurations are properly formatted  
if [[ -n "$(terraform fmt -write=false)" ]]; then echo "Some terraform files need be formatted"; terraform fmt || exit 1; fi  
## terraform init  
find . -type f -name "*.tf" -not -path './modules*' -exec dirname {} \;|sort -u | while read m; do (cd "$m" && echo $m && terraform init) || exit 1; done  
## Validate Terraform configurations  
find . -name '.terraform' -prune -o -type f -name "*.tf" -not -path './modules*' -exec dirname {} \;|sort -u | while read m; do (cd "$m" && echo $m && terraform validate && echo "√ $m") || exit 1 ; done  
tflint --deep  
terraform plan -out tfplan  
terraform apply tfplan  
```  
  
```bash  
## Auto documentation for requirements, inputs, and outputs
curl -Lo ./terraform-docs https://github.com/terraform-docs/terraform-docs/releases/download/v0.10.0-rc.1/terraform-docs-v0.10.0-rc.1-$(uname | tr '[:upper:]' '[:lower:]')-amd64
chmod +x ./terraform-docs
sudo install ./terraform-docs /usr/bin
rm -f terraform-docs
find . -type f -name "*.tf" -not -path './aws-*' -exec dirname {} \;|sort -u | while read m; do (cd "$m" && echo $m && terraform-docs markdown table ./ >> README.md) || exit 1; done  
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.28 |
| aws | ~> 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ubuntu\_account\_number | Variable for AWS AMI's | `string` | `"099720109477"` | no |

## Outputs

| Name | Description |
|------|-------------|
| azs | A list of availability zones spefified as argument to this module |
| canonical\_user\_id | n/a |
| credit\_specification | Credit specification of EC2 instance (empty list for not t2 instance types) |
| default\_vpc\_id | The ID of the VPC |
| ebs\_block\_device\_volume\_ids | List of volume IDs of EBS block devices of instances |
| http\_tcp\_listener\_arns | The ARN of the TCP and HTTP load balancer listeners created. |
| http\_tcp\_listener\_ids | The IDs of the TCP and HTTP load balancer listeners created. |
| https\_listener\_arns | The ARNs of the HTTPS load balancer listeners created. |
| https\_listener\_ids | The IDs of the load balancer listeners created. |
| ids | List of IDs of instances |
| instance\_id | EC2 instance ID |
| instance\_public\_dns | Public DNS name assigned to the EC2 instance |
| nat\_public\_ips | List of public Elastic IPs created for AWS NAT Gateway |
| placement\_group | List of placement group |
| private\_subnets | List of IDs of private subnets |
| public\_dns | List of public DNS names assigned to the instances |
| public\_subnets | List of IDs of public subnets |
| root\_block\_device\_volume\_ids | List of volume IDs of root block devices of instances |
| tags | List of tags |
| target\_group\_arn\_suffixes | ARN suffixes of our target groups - can be used with CloudWatch. |
| target\_group\_arns | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| target\_group\_names | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |
| this\_lb\_arn | The ID and ARN of the load balancer we created. |
| this\_lb\_arn\_suffix | ARN suffix of our load balancer - can be used with CloudWatch. |
| this\_lb\_dns\_name | The DNS name of the load balancer. |
| this\_lb\_id | The ID and ARN of the load balancer we created. |
| this\_lb\_zone\_id | The zone\_id of the load balancer to assist with creating DNS records. |
| this\_security\_group\_description | The description of the security group |
| this\_security\_group\_id | The ID of the security group |
| this\_security\_group\_name | The name of the security group |
| this\_security\_group\_owner\_id | The owner ID |
| this\_security\_group\_vpc\_id | The VPC ID |
| vpc\_cidr\_block | The CIDR block of the VPC |
| vpc\_id | The ID of the VPC |
| vpc\_security\_group\_ids | List of VPC security group ids assigned to the instances |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
