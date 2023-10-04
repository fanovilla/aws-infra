# Self-managed Active Directory

Inspiration from https://gruntwork.io/guides/foundations/how-to-configure-production-grade-aws-account-structure#federated-authentication.

An enterprise org would already have an existing identity provider (IdP), typically Active Directory.

Federated authentication allows auth to AWS accounts using existing AD. Staff don't have to manage multiple
credentials and allowing central maintenance of user accounts.

To simulate this scenario I wanted to play with Azure AD. However, basic Azure subscription apparently doesn't include
AWS SSO capability.

Second option was perhaps use AWS Managed AD in a separate account as the IdP