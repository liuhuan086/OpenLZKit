# Request Examples

本目录展示 Account / Subscription / Project Vending Workflow 的输入形态。它们是文档和 Demo 样例，不会被 CI 自动 apply，也不包含真实账号、租户、订阅、UIN、邮箱或个人信息。

## 流程

```text
business team opens PR
  -> platform team reviews naming, owner, environment and cost tags
  -> CI runs fmt / validate / checkov / conftest
  -> security reviews policy and access scope
  -> terraform plan runs in sandbox
  -> manual approval
  -> apply creates account/subscription/project or onboarding resources
  -> sanitized evidence and workload handoff are recorded
```

## 文件

| 文件 | 云 | 目标 |
|---|---|---|
| [aws-account-request.yaml](aws-account-request.yaml) | AWS | Organizations account vending |
| [alicloud-account-request.yaml](alicloud-account-request.yaml) | 阿里云 | 资源目录账号申请 |
| [azure-subscription-request.yaml](azure-subscription-request.yaml) | Azure | subscription vending |
| [gcp-project-request.yaml](gcp-project-request.yaml) | GCP | project factory |
| [tencentcloud-account-request.yaml](tencentcloud-account-request.yaml) | 腾讯云 | 组织账号申请 |

## 约束

- 所有示例值必须是明显假值，例如 `example.com`、`123456789012`。
- 生产中应接入企业审批、身份源、预算系统和证据归档。
- 各云字段保留原生语义，不强行改成同一个抽象模型。
