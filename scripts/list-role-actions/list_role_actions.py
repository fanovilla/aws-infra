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
        statements = []
        for statement in role_policy["PolicyDocument"]["Statement"]:
            statements.append(f"{statement['Effect']}:[{','.join(statement['Action'])}]")
        policies.append({'source': f"Inline:{role_policy['PolicyName']}", 'actions': statements})

    for managed_policy in raw_role["AttachedManagedPolicies"]:
        statements = []
        local_match = next((item for item in raw_local_policies if item["Arn"] == managed_policy["PolicyArn"]), None)
        if local_match is None:
            policies.append({'source': f"AWS:{managed_policy['PolicyName']}",
                             'actions': ["See https://console.aws.amazon.com/iam/home?#/policies"]})
        else:
            matched_policy = next((item for item in local_match["PolicyVersionList"] if item["IsDefaultVersion"]), None)
            statements = []
            for statement in matched_policy["Document"]["Statement"]:
                statements.append(f"{statement['Effect']}:[{','.join(statement['Action'])}]")
            policies.append({'source': f"LocalManaged:{local_match['PolicyName']}", 'actions': statements})

    roles.append({'name': raw_role["RoleName"], 'action_sets': policies})

print(json.dumps(roles, indent=2, default=str))
