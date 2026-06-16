# AWS Apply Order

## 目的

规定 AWS verified path 的推荐 apply 顺序、前置检查和每层验收。本文遵循 `prompts.md` 第 3 节 Cloud Design 文档要求和第 4 节测试用例要求：每一步都要区分本地静态验证与 sandbox 真实验证。

## 前置条件

- 使用 sandbox AWS Organization，不依赖生产环境。
- 执行身份来自 IAM Identity Center 或 CI OIDC AssumeRole。
- `00-bootstrap` 的 state bucket 已启用版本化、加密、public access block 和 lock table。
- PR 已通过 fmt、validate、TFLint、Checkov、Conftest。

先运行本地 preflight，生成脱敏 readiness 摘要：

```bash
python3 tools/aws_verified_path.py --date YYYY-MM-DD
```

如果需要为 14 层 stack 预创建 evidence summary 模板：

```bash
python3 tools/aws_verified_path.py --date YYYY-MM-DD --write-stack-placeholders
```

该工具不会执行 `terraform apply`；真实 apply 仍必须按下表逐层人工审批。

## 推荐顺序

| 顺序 | Stack | Apply 类型 | 成功标准 | 回滚入口 |
|---:|---|---|---|---|
| 1 | `00-bootstrap` | sandbox apply | state backend 和 CI role 可用 | [terraform-state-recovery](terraform-state-recovery.md) |
| 2 | `10-org` | approval apply | OU 树稳定，账号创建显式 opt-in | [aws-account-vending-failure](aws-account-vending-failure.md) |
| 3 | `15-departments` | approval apply | 部门 OU/role/tag baseline 可查 | [aws-rollback](aws-rollback.md) |
| 4 | `20-identity` | sandbox apply | password policy、boundary、account alias 可查 | [aws-rollback](aws-rollback.md) |
| 5 | `24-cross-account-access` | sandbox apply | OIDC/STS trust 可验证，无 wildcard trust | [ci-oidc-permission-troubleshooting](ci-oidc-permission-troubleshooting.md) |
| 6 | `25-sso` | manual apply | permission set 与 group assignment 可查 | [aws-break-glass-access](aws-break-glass-access.md) |
| 7 | `30-network` | sandbox apply | VPC/subnet/flow logs 正常 | [aws-rollback](aws-rollback.md) |
| 8 | `35-connectivity` | approval apply | TGW route table 隔离符合矩阵 | [aws-rollback](aws-rollback.md) |
| 9 | `40-security` | canary OU apply | SCP/Tag Policy 先附加 sandbox OU | [aws-rollback](aws-rollback.md) |
| 10 | `45-compliance` | delegated apply | Config/Security Hub/GuardDuty enabled | [aws-cloudtrail-audit-check](aws-cloudtrail-audit-check.md) |
| 11 | `50-logging` | approval apply | organization trail 写入 log archive | [aws-cloudtrail-audit-check](aws-cloudtrail-audit-check.md) |
| 12 | `55-delegation` | approval apply | delegated admin service principal 精确 | [aws-rollback](aws-rollback.md) |
| 13 | `60-finops` | sandbox apply | budget、anomaly、CUR 设置可查 | [aws-rollback](aws-rollback.md) |
| 14 | `70-workload-onboarding` | sandbox apply | workload handoff output 可交付 | [aws-rollback](aws-rollback.md) |

## 证据

每层至少保留：

- 脱敏 `terraform plan` 摘要。
- `terraform output` key 与资源类型摘要。
- 相关 Conftest/Checkov/TFLint 输出。
- 对应 AWS CLI/API 查询摘要。
- rollback 判断：可 destroy、需手工 detach、或因保留策略不能删除。

证据文件写入 [../demo/aws-apply-evidence](../demo/aws-apply-evidence/README.md)，plan 摘要写入 [../demo/sanitized-plan-output](../demo/sanitized-plan-output/README.md)。只提交人工复核后的脱敏摘要，不提交 raw plan、state 或云审计原文。
