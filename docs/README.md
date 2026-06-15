# 文档索引

OpenLZKit 的治理方法论文档。每个主题只有一个权威位置，避免重复与漂移。

## learning/ — 概念入门

| 文档 | 内容 |
|---|---|
| [00-what-is-landing-zone](learning/00-what-is-landing-zone.md) | 什么是 Landing Zone、解决什么问题、成熟度演进 |
| [01-from-zero-to-one](learning/01-from-zero-to-one.md) | 从 0 到 1 设计多云 Landing Zone（含各云资源层级示例） |
| [02-multi-account-multi-cloud-role-management](learning/02-multi-account-multi-cloud-role-management.md) | 多账号、多云、多角色管理与权限矩阵 |
| [03-cross-account-and-cross-service-access](learning/03-cross-account-and-cross-service-access.md) | 跨账号、跨服务访问原理与标准方案 |
| [04-detailed-cloud-mapping](learning/04-detailed-cloud-mapping.md) | 五朵云概念映射 |
| [05-multi-cloud-strategy](learning/05-multi-cloud-strategy.md) | 多云策略、目录策略、推荐优先级 |

## design/ — 深入设计

| 文档 | 内容 |
|---|---|
| [00-enterprise-principles](design/00-enterprise-principles.md) | 企业级设计原则（统一标准 + 独立实现） |
| [01-identity-access-design](design/01-identity-access-design.md) | 身份与访问设计 |
| [02-network-design](design/02-network-design.md) | 网络设计（含多云互联优先级） |
| [03-security-governance-design](design/03-security-governance-design.md) | 安全治理与策略设计 |
| [04-iac-and-cicd-design](design/04-iac-and-cicd-design.md) | IaC 与 CI/CD 设计 |
| [05-repository-and-state-design](design/05-repository-and-state-design.md) | 仓库与 state 设计 |
| [05-repository-and-state-design-en](design/05-repository-and-state-design-en.md) | 仓库与 state 设计英文版 |
| [06-alicloud-landing-zone-design](design/06-alicloud-landing-zone-design.md) | 阿里云设计 |
| [07-aws-landing-zone-design](design/07-aws-landing-zone-design.md) | AWS 设计 |
| [08-tencent-cloud-landing-zone-design](design/08-tencent-cloud-landing-zone-design.md) | 腾讯云设计 |
| [09-azure-landing-zone-design](design/09-azure-landing-zone-design.md) | Azure 设计 |
| [10-gcp-landing-zone-design](design/10-gcp-landing-zone-design.md) | Google Cloud 设计 |
| [11-logging-audit-observability](design/11-logging-audit-observability.md) | 日志、审计与可观测性 |
| [12-finops-cost-governance](design/12-finops-cost-governance.md) | FinOps 与成本治理 |

## runbooks/ — 运维与问题处置

| 文档 | 内容 |
|---|---|
| [01-operations-runbook](runbooks/01-operations-runbook.md) | 运维手册（新增账号/角色/策略、drift、break-glass） |
| [02-common-problems-and-solutions](runbooks/02-common-problems-and-solutions.md) | 常见问题与标准解决方案 |
| [aws-apply-order](runbooks/aws-apply-order.md) | AWS verified path apply 顺序、验收与证据 |
| [aws-rollback](runbooks/aws-rollback.md) | AWS 常见回滚路径 |
| [aws-break-glass-access](runbooks/aws-break-glass-access.md) | AWS break-glass 访问流程 |
| [aws-drift-detection](runbooks/aws-drift-detection.md) | AWS drift 检测与处置 |
| [aws-account-vending-failure](runbooks/aws-account-vending-failure.md) | AWS account vending 失败处理 |
| [aws-cloudtrail-audit-check](runbooks/aws-cloudtrail-audit-check.md) | AWS CloudTrail 审计检查 |
| [terraform-state-recovery](runbooks/terraform-state-recovery.md) | Terraform state 恢复流程 |
| [ci-oidc-permission-troubleshooting](runbooks/ci-oidc-permission-troubleshooting.md) | CI OIDC 权限排障 |

## demo/ — 可验证样板与演示

| 文档 | 内容 |
|---|---|
| [aws-sandbox-apply-report](demo/aws-sandbox-apply-report.md) | AWS sandbox apply / dry-run / evidence 报告模板 |

## compliance/ — 控制映射

| 文档 | 内容 |
|---|---|
| [control-mapping](compliance/control-mapping.md) | 跨云控制目标、云原生实现、Rego 检查与证据映射 |

## 跨切面文档

| 文档 | 内容 |
|---|---|
| [testing-strategy](testing-strategy.md) | 测试分层、PR 门禁、生产发布门禁 |
| [outputs-and-acceptance](outputs-and-acceptance.md) | 输出物与验收标准 |
| [releases](releases.md) | release 路线与发布清单 |
| [v0.1.0 release notes](release-notes/v0.1.0.md) | Documentation + Static Validation Release 说明 |
| [references](references.md) | 各云官方文档链接 |
