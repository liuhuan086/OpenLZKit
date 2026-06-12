# OpenLZKit Test Cases

| ID | Category | Cloud | Target | Preconditions | Steps | Expected Result | Risk |
|---|---|---|---|---|---|---|---|
| TC-001 | Format | All | Terraform code | repo checked out | Run `terraform fmt -check -recursive` | No diff | Low |
| TC-002 | Validate | All | Each module example | provider init available | Run `terraform init && terraform validate` | Validate success | Medium |
| TC-003 | Lint | All | HCL | TFLint installed | Run `tflint --recursive` | No critical lint error | Medium |
| TC-004 | Security | All | HCL | Checkov/tfsec installed | Run security scan | No high severity issue | High |
| TC-005 | Policy | All | Plan JSON | OPA/Conftest installed | Run custom policy | Required tags, encryption, no public high-risk ingress | High |
| TC-006 | State | All | live stack | backend configured | Init remote backend | State stored remotely and locked | High |
| TC-007 | Identity | All | CI/CD role | sandbox credentials | Plan with CI role | Only allowed stack can plan/apply | High |
| TC-008 | Logging | All | Audit baseline | sandbox environment | Create test event | Event appears in central log | High |
| TC-009 | Network | All | Network baseline | sandbox environment | Deploy example VPC/VNet/network | No public ingress by default | High |
| TC-010 | FinOps | All | Tags | sample resource | Plan without required tag | Policy fails | Medium |
| TC-011 | Drift | All | live stack | resource deployed | Change resource manually then plan | Drift detected | Medium |
| TC-012 | Rollback | All | module release | previous version available | Revert module version | Rollback path documented | High |
