# AWS Landing Zone

## 定位

本目录是 OpenLZKit 针对 AWS 的独立 Landing Zone 设计与实现目录。它遵循 AWS 原生治理模型，不强行套用其他云的账号、网络或权限结构。

## 原生治理模型

- 推荐基础：AWS Organizations / Control Tower / AFT
- 关键能力：Account, OU, IAM Identity Center, SCP, CloudTrail, Config, Security Hub, Transit Gateway

## 目录

```text
aws/
├── README.md
├── docs/
├── modules/
├── live/
├── policies/
├── examples/
└── tests/
```

## 实现状态

| 层 | 实现 | 状态 |
|---|---|---|
| `00-bootstrap` | [`live/00-bootstrap`](live/00-bootstrap) | 🟡 骨架目录 |
| `10-org` | [`live/10-org`](live/10-org), [`modules/org`](modules/org), [`modules/account-factory`](modules/account-factory) | ✅ 第一版（Organizations OU / account vending） |
| `15-departments` | [`live/15-departments`](live/15-departments), [`modules/department`](modules/department) | ✅ 第一版（department OU / admin role / tag baseline） |
| `20-identity` | [`modules/identity`](modules/identity) | 🟡 骨架目录（基础 IAM 边界待补） |
| `24-cross-account-access` | [`live/24-cross-account-access`](live/24-cross-account-access), [`modules/cross-account-access`](modules/cross-account-access) | ✅ 第一版（STS / OIDC / RAM sharing） |
| `25-sso` | [`live/25-sso`](live/25-sso), [`modules/identity-center`](modules/identity-center) | ✅ 第一版（IAM Identity Center permission sets / assignments） |
| `30-network` | [`modules/network`](modules/network) | 🟡 待实现（VPC baseline） |
| `35-connectivity` | [`live/35-connectivity`](live/35-connectivity), [`modules/connectivity`](modules/connectivity) | ✅ 第一版（Transit Gateway / RAM sharing） |
| `40-security` | [`live/40-security`](live/40-security), [`modules/org-policies`](modules/org-policies) | ✅ 第一版（SCP / Tag Policy guardrails） |
| `45-compliance` | [`live/45-compliance`](live/45-compliance), [`modules/compliance`](modules/compliance) | ✅ 第一版（AWS Config / Security Hub / GuardDuty） |
| `50-logging` | [`live/50-logging`](live/50-logging), [`modules/logging`](modules/logging) | ✅ 第一版（CloudTrail / log archive / Object Lock） |
| `55-delegation` | [`live/55-delegation`](live/55-delegation), [`modules/delegation`](modules/delegation) | ✅ 第一版（Delegated Admin / governed RAM sharing） |
| `60-finops` | [`live/60-finops`](live/60-finops), [`modules/finops`](modules/finops) | ✅ 第一版（Budgets / Cost Anomaly / Cost Categories） |
| `70-workload-onboarding` | [`modules/workload-onboarding`](modules/workload-onboarding) | 🟡 待实现（workload account/resource baseline） |

## 企业级深化

在 MVP 七域之上，按企业级标准深化多账号、跨账号访问、业务部门管理、组织护栏、IAM Identity Center、Transit Gateway、AWS Config/Security Hub/GuardDuty、委派管理、日志归档与 FinOps。功能点路线图见 [docs/enterprise-scenarios.md](docs/enterprise-scenarios.md)（文档先行，逐 FP 推进）。

## live stack 顺序

1. `00-bootstrap`：远程 state、CI/CD 角色、初始审计。
2. `10-org`：AWS Organizations OU 基线与账号售卖入口。
3. `15-departments`：业务部门 OU、部门管理员角色、部门标签基线。
4. `20-identity`：SSO、角色、权限边界。
5. `24-cross-account-access`：安全、CI/CD、日志、网络等跨账号访问路径。
6. `25-sso`：IAM Identity Center permission set 与账号分配。
7. `30-network`：网络基线。
8. `35-connectivity`：Transit Gateway、路由表隔离、AWS RAM 网络共享。
9. `40-security`：安全基线和 Guardrails。
10. `45-compliance`：AWS Config、Security Hub、GuardDuty 运行时合规。
11. `50-logging`：日志审计与集中归档。
12. `55-delegation`：Organizations delegated administrator 与 RAM 共享治理。
13. `60-finops`：标签、预算、成本告警。
14. `70-workload-onboarding`：业务接入模板。

## MVP 范围

- 设计文档。
- 模块接口草案。
- 最小组织结构。
- 最小身份模型。
- 最小日志审计。
- 基础安全基线。
- 一个 workload onboarding 示例。
