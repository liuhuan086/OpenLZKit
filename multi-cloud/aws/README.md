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
| `20-identity` | [`modules/identity`](modules/identity) | 🟡 待实现（IAM roles / Identity Center 对接） |
| `30-network` | [`modules/network`](modules/network) | 🟡 待实现（VPC baseline） |
| `40-security` | [`live/40-security`](live/40-security), [`modules/org-policies`](modules/org-policies) | ✅ 第一版（SCP / Tag Policy guardrails） |
| `50-logging` | [`modules/logging`](modules/logging) | 🟡 待实现（CloudTrail / log archive） |
| `60-finops` | [`modules/finops`](modules/finops) | 🟡 待实现（Budgets / Cost Anomaly / Cost Categories） |
| `70-workload-onboarding` | [`modules/workload-onboarding`](modules/workload-onboarding) | 🟡 待实现（workload account/resource baseline） |

## 企业级深化

在 MVP 七域之上，按企业级标准深化多账号、跨账号访问、业务部门管理、组织护栏、IAM Identity Center、Transit Gateway、AWS Config/Security Hub/GuardDuty、委派管理、日志归档与 FinOps。功能点路线图见 [docs/enterprise-scenarios.md](docs/enterprise-scenarios.md)（文档先行，逐 FP 推进）。

## live stack 顺序

1. `00-bootstrap`：远程 state、CI/CD 角色、初始审计。
2. `10-org`：AWS Organizations OU 基线与账号售卖入口。
3. `20-identity`：SSO、角色、权限边界。
4. `30-network`：网络基线。
5. `40-security`：安全基线和 Guardrails。
6. `50-logging`：日志审计与集中归档。
7. `60-finops`：标签、预算、成本告警。
8. `70-workload-onboarding`：业务接入模板。

## MVP 范围

- 设计文档。
- 模块接口草案。
- 最小组织结构。
- 最小身份模型。
- 最小日志审计。
- 基础安全基线。
- 一个 workload onboarding 示例。
