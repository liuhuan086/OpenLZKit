# Example: AWS workload onboarding

Shows how a platform team can publish a workload onboarding contract after the
account, network, connectivity and SSO foundations already exist.

```bash
terraform -chdir=multi-cloud/aws/examples/workload-onboarding init -backend=false
terraform -chdir=multi-cloud/aws/examples/workload-onboarding validate
```
