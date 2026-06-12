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
| `10-org` | [`modules/org`](modules/org) | ✅ 已实现（Resource Directory 文件夹层级，账号创建默认关闭） |
| `20-identity` | [`modules/identity`](modules/identity) | ✅ 已实现（可假设 RAM 角色，SSO/联邦导向，不建长期用户） |
| `30-network` | [`modules/network`](modules/network) | ✅ 已实现（Hub-Spoke VPC/VSwitch + 默认拒绝安全组） |
| `40-security` | [`modules/security`](modules/security) | ✅ 已实现（RAM 密码策略 + 安全偏好：强制 MFA、禁用户管 AK） |
| `50-logging` | [`modules/logging`](modules/logging) | ✅ 已实现（SLS 审计项目/日志库 + ActionTrail 组织级审计） |
| 其他层 | — | 🚧 占位，待实现 |

所有已实现 stack 均通过 `terraform fmt + validate`（无需云账号）。参见 [examples/basic](examples/basic)。

## live stack 顺序

1. `00-bootstrap`：远程 state、CI/CD 角色、初始审计。
2. `10-org`：组织、账号/订阅/项目/文件夹结构。
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
