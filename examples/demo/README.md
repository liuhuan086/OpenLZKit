# Demo Mode

Demo Mode 让没有云账号的读者也能理解 OpenLZKit 解决什么问题。它不创建真实资源，而是用业务申请、预期组织结构、预期网络和控制清单串起一条可评审路径。

## 场景

一家 80 人创业公司准备把核心业务放到 AWS：

- 需要 `management`、`security`、`logging`、`network`、`dev`、`prod` 账号。
- `dev` 和 `prod` 网络隔离，生产只通过共享网络出口访问公共服务。
- 所有资源必须有 `owner`、`cost_center`、`environment`、`managed_by` 标签。
- 禁止公开对象存储，禁止未加密 state bucket。
- CI/CD 只能通过 OIDC AssumeRole，不允许长期 access key。
- 新 workload 通过 PR 申请接入，平台团队 review 后 apply。

## 文件

| 文件 | 作用 |
|---|---|
| [aws-small-company/org-request.yaml](aws-small-company/org-request.yaml) | 组织/OU 申请 |
| [aws-small-company/account-request.yaml](aws-small-company/account-request.yaml) | AWS account vending 申请 |
| [aws-small-company/workload-request.yaml](aws-small-company/workload-request.yaml) | workload onboarding 申请 |
| [aws-small-company/expected-ou-tree.md](aws-small-company/expected-ou-tree.md) | 预期 OU/账号树 |
| [aws-small-company/expected-network.md](aws-small-company/expected-network.md) | 预期网络隔离和互联 |
| [aws-small-company/expected-controls.md](aws-small-company/expected-controls.md) | 预期安全、身份、成本和策略控制 |

跨云 account/subscription/project request 样例见 [../../request](../../request)。

## Review Flow

```text
Business request
  -> platform review
  -> schema / naming / tag check
  -> terraform fmt / validate
  -> checkov / tflint
  -> conftest policy test
  -> terraform plan in sandbox
  -> manual approval
  -> apply
  -> sanitized evidence report
  -> workload handoff
```
