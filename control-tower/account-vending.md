# Account Vending

Exploration on ways to implement a multi-account structure.
See https://gruntwork.io/guides/foundations/how-to-configure-production-grade-aws-account-structure

Account vending a.k.a account factory, account builder

## Pathways

### Control Tower

https://docs.aws.amazon.com/controltower/latest/userguide/account-factory.html

### AWS Landing Zone

https://aws.amazon.com/solutions/implementations/aws-landing-zone/

* Creating an IAM user with the provided password.
* Adding the IAM user to a new group with least privilege permissions to access AWS Service Catalog.
* Deploying baseline templates for creating AWS Service Catalog portfolio and products.
* Deleting the default VPCs in all AWS Regions.
* Creating AWS Service Catalog products and portfolio inside the newly created account.
* Adding the provided IAM user and IAM role as principals to the created AWS Service Catalog portfolio.

### aws-account-vending-machine

https://github.com/aws-samples/aws-account-vending-machine


### Terraform Landing Zone

* https://www.hashicorp.com/resources/aws-terraform-landing-zone-tlz-accelerator
* https://www.hashicorp.com/resources/terraform-landing-zones-for-self-service-multi-aws-at-eventbrite
* Only available via AWS ProServ - https://discuss.hashicorp.com/t/tfm-landing-zone/21028

## Literature

* https://aws.amazon.com/blogs/mt/how-to-automate-the-creation-of-multiple-accounts-in-aws-control-tower/

