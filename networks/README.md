# networks

## vpcs

Creates `mgmt` and `app` VPCs as described in 
[production-grade VPC](https://gruntwork.io/guides/networking/how-to-deploy-production-grade-vpc-aws/#multiple_vpcs).

In each vpc, subnets are created under groups `private`, `public`, and `persistence`; as described in
[subnet tiers](https://gruntwork.io/guides/networking/how-to-deploy-production-grade-vpc-aws/#multiple_subnets).

Each tier has 3 subnets distributed across availability zones.

Subnet names are prefixed by the VPC name they are a part of:
* app.public1
* app.public2
* app.public3
* app.private1
* app.private2
* app.private3
* app.persistence1
* app.persistence2
* app.persistence3
* mgmt.public1
* mgmt.public2
* mgmt.public3
* mgmt.private1
* mgmt.private2
* mgmt.private3
* mgmt.persistence1
* mgmt.persistence2
* mgmt.persistence3


## nacls

Prefixes for origin and target below. 
* s. - subnet group
* v. - vpc
* x. - external; where refs are assumed to be terraform locals

Rule defs below currently assume TCP.

### Ruleset

Regular egress rules below, from a subnet group traffic origin.
The contra ingress rules gets provisioned as well with ephemeral port range.


| source subnet group | target            | port |
| ---                 | ---               | ---  |
| s.app_public        | s.app_private     | 443  |
| s.app_public        | x.aws_s3          | 443  |
| s.app_private       | s.app_persistence | 3306 |
| s.app_private       | s.app_persistence | 22   |
| s.app_private       | x.onprem_ldap     | 636  |
| s.app_private       | x.aws_s3          | 443  |
| s.mgmt_public       | s.mgmt_private    | 443  |
| s.mgmt_private      | v.mgmt            | 22   |
| s.mgmt_private      | x.onprem_ldap     | 636  |
| s.mgmt_private      | v.app             | 22   |
| x.universe      | s.app_public            | 443   |
| x.universe      | s.mgmt_public              | 443   |


### Inbound From Externals Ruleset

These rules allow traffic in from somewhere external to our network.
The contra egress rules gets provisioned as well with ephemeral port range.

Target will always be subnet groups.
Source is always an external ref (on-premise hosts, third-parties, etc)

| target subnet group | origin     | port |
| ---                 | ---        | ---  |
| s.app_public        | x.universe | 443  |
| s.mgmt_public       | x.universe | 443  |


### Provisioning

On an account/vpc
* collect all subnets; build these data structures
  * subnet_ids_list -
  * subnet_group_map - key is subnet group, value is list of subnet ids in group  
* for each key in subnet_group_map, create nacl (would contain deny default), attach to subnet ids
* for each subnet collect subnet name, subnet group, nacl id; subnet list
* for each subnet group
  * for each rule in ruleset where source = subnet group
    * for each cidr in refs_lookup(target)
      * rule egress




## References

* https://www.davidc.net/sites/default/subnets/subnets.html