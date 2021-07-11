# Control Tower

## Setup

### Prerequisites

https://docs.aws.amazon.com/controltower/latest/userguide/getting-started-with-control-tower.html

* create a new account - used a [task-specific gmail address](https://support.google.com/a/users/answer/9308648?hl=en), e.g. `me+aws01-audit@gmail.com`
* setup MFA on root user - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html#id_root-user_manage_mfa
* create Administrator IAM user - https://docs.aws.amazon.com/controltower/latest/userguide/setting-up.html

### Setup Landing Zone

* Home Region - US East (N. Virginia) - mainly so we can play with new services
* Additional AWS Regions for governance - none - Guidance here is to select regions you plan to run workloads in
* Foundational OU - Security (default) - contains three shared accounts: the management (primary) account, the log archive account, and the security audit account (also referred to as the audit account).
* Additional OU - Sandbox (default) - can be used to store any production or development accounts. You can create more OUs after setting up your landing zone
* Management account - default - uses your existing AWS account email address and is used for billing and management of your accounts and landing zone
* Log archive account - ideally the email of another identity, for convenience used another task-specific address, e.g. `me+aws01-log-archive@gmail.com`
* Audit account - ideally the email of another identity, for convenience used another task-specific address, e.g. `me+aws01-audit@gmail.com`

#### Review

Permission to administer service control policies (SCPs) in your organization

AWS Control Tower uses SCPs to enforce preventive guardrails on your organizational units (OUs), and therefore requires
permission to create, modify, and attach SCPs. Also, AWS Control Tower may read the contents of SCPs created by AWS
Control Tower periodically, to verify that preventive guardrails are enabled on your account. AWS Control Tower does
not read the contents of SCPs that were not created by AWS Control Tower.

4 IAM roles

1. Role name: AWSControlTowerAdmin
   Purpose: This role provides AWS Control Tower with access to infrastructure critical to maintaining the landing zone.
   - AWSControlTowerServiceRolePolicy
   - ec2:DescribeAvailabilityZones

2. Role name: AWSControlTowerStackSetRole
   Purpose: AWS CloudFormation assumes this role to deploy stacksets in accounts created by AWS Control Tower.
    - sts:AssumeRole role/AWSControlTowerExecution
    
3. Role name: AWSControlTowerCloudTrailRole
   Purpose: AWS Control Tower enables CloudTrail as a best practice and provides this role to AWS CloudTrail. 
   AWS CloudTrail assumes this role to create and publish CloudTrail logs.
    - logs:CreateLogStream
    - logs:PutLogEvents
    
4. Role name: AWSControlTowerConfigAggregatorRoleForOrganizations
   Purpose: For the AWS Config aggregator to work with AWS Organizations, AWS Control Tower must create a new role, 
   called AWSControlTowerConfigAggregatorRoleForOrganizations, which has the permissions needed to describe the 
   organization and list the accounts under it. AWSControlTowerConfigAggregatorRoleForOrganizations requires the
    - sts:AssumeRole config.amazonaws.com

#### Guidance
We strongly recommend that you follow the guidance below when you use AWS Control Tower. This guidance may change as we continue to update the service.

General guidance

Do not modify or delete resources created by AWS Control Tower in the management account or in the shared accounts. Modification of these resources can require an update to your landing zone.
Do not modify or delete the AWS Identity and Access Management (IAM) roles created within the shared accounts in the core organizational unit (OU). Modification of these resources can require an update to your landing zone.
For more information on the resources created by AWS Control Tower, see Resources  in the AWS Control Tower User Guide.
AWS Organizations guidance

Do not use AWS Organizations to update service control policies (SCPs) that are attached by AWS Control Tower to an AWS Control Tower managed OU. Doing so could result in the guardrails entering an unknown state, which will require you to re-enable affected guardrails in AWS Control Tower.
If you use AWS Organizations to create, invite, or move accounts within an organization created by AWS Control Tower, those outside accounts will not be managed by AWS Control Tower and will not appear in the Accounts table.
If you use AWS Organizations to create or move OUs within an organization created by AWS Control Tower, those outside OUs will not be managed by AWS Control Tower and will not appear in the Organizational units table.
If you use AWS Organizations to rename or delete an OU that was created by AWS Control Tower, then this OU will continue to be displayed by AWS Control Tower using its original name. You will not be able to provision a new account to this OU using AWS Control Tower account factory.
AWS Single Sign-On guidance

If you reconfigure your directory in AWS Single Sign-On to Active Directory, all preconfigured users and groups in AWS SSO will be deleted.
Account factory guidance

When you use account factory to provision new accounts in AWS Service Catalog, do not define TagOptions, enable notifications, or create a provisioned product plan. Doing so can result in a failure to provision a new account.
For more information, see the AWS Control Tower User Guide .

#### Your landing zone is being set up

Setting up your landing zone

Estimated time remaining: 60 minutes.
AWS Control Tower is setting up the following:

2 organizational units, one for your shared accounts and one for accounts that will be provisioned by your users.
3 shared accounts, which are the management account and isolated accounts for log archive and security audit.
A native cloud directory with preconfigured groups and single sign-on access.
20 preventive guardrails to enforce policies and 2 detective guardrails to detect configuration violations.


####

* AWS Organizations email verification request - sent to root account email - verify link
* Invitation to join AWS Single Sign-On - sent by control tower to root account email - accepting means setting up new password; didn't continue
* AWS Notification - Subscription Confirmation - sent to audit email - confirm, this is for security notifications



## Billing Alarms

Using root user
* Enable cost explorer
* Setup monthly $10 budget
* Setup alert at 80% forecasted, email to root email address