# live/25-sso (GCP)

Human access (FP-5): Cloud Identity security groups (`platform-admins`,
`security-auditors`) granted editor/viewer at the org root folder. Membership is
managed via the IdP; groups receive IAM, not users.

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan \
  -var project_id=<project> \
  -var customer_id=customers/C0xxxxxxx \
  -var domain=example.com \
  -var org_folder=folders/<root-folder-id>
# requires Cloud Identity admin to create groups; apply after PR review + approval
```
