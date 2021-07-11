# networks

## vpcs

Creates `mgmt` and `app` VPCs as described in 
[production-grade VPC](https://gruntwork.io/guides/networking/how-to-deploy-production-grade-vpc-aws/#multiple_vpcs).

In each vpc, subnets are created under groups `private`, `public`, and `persistence`; as described in
[subnet tiers](https://gruntwork.io/guides/networking/how-to-deploy-production-grade-vpc-aws/#multiple_subnets).

Each group has 3 subnets distributed across availability zones.

Subnet names are prefixed by the VPC name they are a part of:
* app_public_1
* app_public_2
* app_public_3
* app_private_1
* app_private_2
* app_private_3
* app_persistence_1
* app_persistence_2
* app_persistence_3
* mgmt_public_1
* mgmt_public_2
* mgmt_public_3
* mgmt_private_1
* mgmt_private_2
* mgmt_private_3
* mgmt_persistence_1
* mgmt_persistence_2
* mgmt_persistence_3


## nacls

Declarative nacl ruleset spec as table below, encoded in a [csv](nacls/subnet_group_ruleset.csv) file.

| source              | target          | port |
| ---                 | ---             | ---  |
| app_public          | app_private     | 443  |
| app_public          | _aws_s3         | 443  |
| app_private         | app_persistence | 3306 |
| app_private         | app_persistence | 22   |
| app_private         | _onprem_ldap    | 636  |
| app_private         | _aws_s3         | 443  |
| mgmt_public         | mgmt_private    | 443  |
| mgmt_private        | _vpc_mgmt       | 0    |
| mgmt_private        | _vpc_app        | 0    |
| mgmt_private        | _onprem_ldap    | 636  |
| _universe           | app_public      | 443  |
| _universe           | mgmt_public     | 443  |

Notes
* each value in the source and target columns is a 'ruleset ref'
* a 'ruleset ref' can be either a subnet group name, or a 'CIDR group alias' (those starting with an underscore)
* a 'CIDR group alias' is a named collection of CIDRs (e.g., CIDRs of a VPC, CIDRs of an on-prem service, etc.)
* each entry encodes the 'request' traffic, nacl rules for return traffic using ephemeral ports gets created as well
* the ruleset is for allow rules only; a default deny rule (all protocols) exists when the nacl is created
* a port value of 0 means traffic is valid for all protocols; else tcp protocol is assumed  
* no rule numbers, assumption is that the entries in the ruleset are equal in weight
  * this models the way connectivity between subnets are drawn - there's no implied order in the connection arrows
  * means rule numbering is left to the machinery (currently using 1000-5000 range)


## References

* https://www.davidc.net/sites/default/subnets/subnets.html