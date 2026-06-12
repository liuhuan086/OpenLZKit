# Alibaba Cloud Landing Zone

## 定位

本目录是 OpenLZKit 针对 Alibaba Cloud 的独立 Landing Zone 设计与实现目录。它遵循 Alibaba Cloud 原生治理模型，不强行套用其他云的账号、网络或权限结构。

## 原生治理模型

- 推荐基础：Resource Directory / Cloud Governance Center
- 关键能力：Resource Directory, folders, RAM, CloudSSO, ActionTrail, Config, CEN, OSS Log Archive

## 目录

```text
alicloud/
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
| `00-bootstrap` | [`live/00-bootstrap`](live/00-bootstrap) | ✅ 已实现（启用 Resource Directory、OSS state 桶、GitHub OIDC + CI/CD plan 角色） |
| `10-org` | [`modules/org`](modules/org) + [`modules/account-factory`](modules/account-factory) | ✅ 已实现（Resource Directory 文件夹层级 + opt-in 账号工厂，账号创建默认关闭） |
| `15-departments` | [`modules/department`](modules/department) | ✅ 已实现（部门 folder + 部门角色 + 部门标签策略 + 部门级管控策略附加） |
| `20-identity` | [`modules/identity`](modules/identity) | ✅ 已实现（可假设 RAM 角色，SSO/联邦导向，不建长期用户） |
| `24-cross-account-access` | [`modules/cross-account-access`](modules/cross-account-access) | ✅ 已实现（跨账号 RAM 角色 + STS trust condition + Resource Share） |
| `25-sso` | [`modules/sso`](modules/sso) | ✅ 已实现（CloudSSO directory + group + access configuration + assignment） |
| `30-network` | [`modules/network`](modules/network) | ✅ 已实现（Hub-Spoke VPC/VSwitch + 默认拒绝安全组） |
| `35-connectivity` | [`modules/connectivity`](modules/connectivity) | ✅ 已实现（CEN + Transit Router + VPC attachment + 跨账号 grant + 路由表） |
| `40-security` | [`modules/security`](modules/security) + [`modules/control-policies`](modules/control-policies) | ✅ 已实现（RAM 密码策略 + 安全偏好 + opt-in 组织管控策略） |
| `45-compliance` | [`modules/compliance`](modules/compliance) | ✅ 已实现（Cloud Config recorder + aggregator + aggregate rules + compliance packs + delivery） |
| `50-logging` | [`modules/logging`](modules/logging) | ✅ 已实现（SLS 审计项目/日志库 + ActionTrail 组织级审计） |
| `55-delegation` | [`modules/delegation`](modules/delegation) | ✅ 已实现（委派管理员 + CloudSSO 委派账号 + Resource Share） |
| `60-finops` | [`modules/finops`](modules/finops) | ✅ 已实现（标签策略强制 FinOps 标签集） |
| `70-workload-onboarding` | [`modules/workload-onboarding`](modules/workload-onboarding) | ✅ 已实现（资源组 + 工作负载角色 + 标准标签模板） |

所有已实现 stack 均通过 `terraform fmt + validate`（无需云账号）。参见 [examples/basic](examples/basic)。

## 企业级深化

在 MVP 七域之上，按企业级标准深化多账号、跨账号访问、业务部门管理、组织护栏、CloudSSO、网络互联与集中合规。功能点路线图见 [docs/enterprise-scenarios.md](docs/enterprise-scenarios.md)（文档先行，逐 FP 推进）。

## live stack 顺序

1. `00-bootstrap`：远程 state、CI/CD 角色、初始审计。
2. `10-org`：组织、账号/订阅/项目/文件夹结构（账号工厂默认空输入）。
3. `15-departments`：业务部门 folder、部门角色、部门标签策略。
4. `20-identity`：SSO、角色、权限边界。
5. `24-cross-account-access`：跨账号角色、STS trust、资源共享。
6. `25-sso`：CloudSSO 人员访问、权限配置、账号分配。
7. `30-network`：网络基线。
8. `35-connectivity`：CEN/Transit Router 跨账号网络互联。
9. `40-security`：安全基线和 Guardrails。
10. `45-compliance`：Cloud Config 运行时合规聚合。
11. `50-logging`：日志审计与集中归档。
12. `55-delegation`：委派管理员、CloudSSO 委派账号、资源共享。
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
