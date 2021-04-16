import json
import logging

import boto3

logger = logging.getLogger('tcpserver')
client = boto3.client('iam')

response = client.get_account_authorization_details(
    Filter=[
        'Role', 'LocalManagedPolicy',  # 'User'|'Role'|'Group'|'LocalManagedPolicy'|'AWSManagedPolicy',
    ],
)

raw_roles = response["RoleDetailList"]
raw_local_policies = response["Policies"]

roles = []
for raw_role in raw_roles:
    policies = []

    for role_policy in raw_role["RolePolicyList"]:
        allow_actions = []
        deny_actions = []
        for statement in role_policy["PolicyDocument"]["Statement"]:
            effect = statement['Effect']
            if effect == 'Allow':
                allow_actions.extend(statement['Action'])
            elif effect == 'Deny':
                deny_actions.extend(statement['Action'])
            else:
                raise Exception("Unrecognized effect")
        if deny_actions:
            policies.append({'source': f"Inline:{role_policy['PolicyName']}", 'allow_actions': allow_actions,
                             'deny_actions': deny_actions})
        else:
            policies.append({'source': f"Inline:{role_policy['PolicyName']}", 'allow_actions': allow_actions})

    for managed_policy in raw_role["AttachedManagedPolicies"]:
        statements = []
        local_match = next((item for item in raw_local_policies if item["Arn"] == managed_policy["PolicyArn"]), None)
        if local_match is None:
            policies.append({'source': f"AWSManaged:{managed_policy['PolicyName']}",
                             'allow_actions': ["See https://console.aws.amazon.com/iam/home?#/policies"]})
        else:
            matched_policy = next((item for item in local_match["PolicyVersionList"] if item["IsDefaultVersion"]), None)
            allow_actions = []
            deny_actions = []
            for statement in matched_policy["Document"]["Statement"]:
                effect = statement['Effect']
                if effect == 'Allow':
                    allow_actions.extend(statement['Action'])
                elif effect == 'Deny':
                    deny_actions.extend(statement['Action'])
                else:
                    raise Exception("Unrecognized effect")
            if deny_actions:
                policies.append({'source': f"LocalManaged:{local_match['PolicyName']}", 'allow_actions': allow_actions,
                                 'deny_actions': deny_actions})
            else:
                policies.append({'source': f"LocalManaged:{local_match['PolicyName']}", 'allow_actions': allow_actions})

    roles.append({'name': raw_role["RoleName"], 'action_sets': policies})

print(json.dumps(roles, indent=2, default=str, ))
