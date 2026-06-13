# live/35-connectivity (GCP)

Shared VPC interconnect (FP-6): enable the Shared VPC host (the network host
project from `30-network`) and attach service projects. Service projects are
empty by default — never attach sandbox to the production host.

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan \
  -var project_id=<project> \
  -var host_project=<host-project> \
  -var 'service_projects={prod={service_project="lz-payment-prod"}}'
# apply after PR review + approval
```
