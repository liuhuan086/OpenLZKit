# Google Cloud Landing Zone

## 定位

本目录是 OpenLZKit 针对 Google Cloud 的独立 Landing Zone 设计与实现目录。它遵循 Google Cloud 原生治理模型，不强行套用其他云的账号、网络或权限结构。

## 原生治理模型

- 推荐基础：Organization / Folders / Projects / Cloud Foundation
- 关键能力：Organization, Folders, Projects, IAM, Org Policy, Shared VPC, Cloud Logging, SCC

## 目录

```text
gcp/
├── README.md
├── docs/
├── modules/
├── live/
├── policies/
├── examples/
└── tests/
```

## 实现状态

🚧 实现进行中（文档先行）。功能点路线图见 [docs/enterprise-scenarios.md](docs/enterprise-scenarios.md)，按 FP 逐轮交付，每个 stack 通过 CI 五道门禁（fmt / validate / tflint / checkov / conftest）。

| 层 | 实现 | 状态 |
|---|---|---|
| `00-bootstrap` | [`live/00-bootstrap`](live/00-bootstrap) | ✅ 已实现（GCS state 桶 + GitHub WIF + CI 服务账号） |
| `10-org` | [`modules/org`](modules/org), [`modules/project-factory`](modules/project-factory) | ✅ 已实现（Folder 层级 + 项目工厂 FP-1，项目创建默认关闭） |
| `15-departments` | [`modules/department`](modules/department) | ✅ 已实现（FP-3：部门 Folder + 部门 IAM + 部门预算） |
| `20-identity` | [`modules/identity`](modules/identity) | ✅ 已实现（自定义 IAM 角色 + 绑定，组优先） |
| `24-cross-account-access` | [`modules/cross-account-access`](modules/cross-account-access) | ✅ 已实现（FP-4：服务账号 + WIF 模拟 + 跨项目 IAM） |
| `25-sso` | [`modules/identity-groups`](modules/identity-groups) | ✅ 已实现（FP-5：Cloud Identity 组 + IAM，人员走组不走用户） |
| `30-network` | [`modules/network`](modules/network) | ✅ 已实现（Shared VPC 自定义网络 + 子网流日志 + 默认拒绝防火墙） |
| `40-security` | [`modules/org-policies`](modules/org-policies) | ✅ 已实现（Organization Policy 组织护栏 FP-2：禁 SA key/默认网络/外网 IP，限地域） |
| `50-logging` | [`modules/logging`](modules/logging) | ✅ 已实现（中央日志归档桶 + 聚合 Folder 日志 sink） |
| `60-finops` | [`modules/finops`](modules/finops) | ✅ 已实现（Cloud Billing 预算 + 阈值告警） |
| 其他层 | — | 🚧 待实现（见路线图） |

## 企业级深化

与阿里云 / AWS / Azure 保持同一套治理标准，按 GCP 原生模型深化多账号（项目工厂）、组织护栏（Organization Policy）、业务部门、跨项目访问、Cloud Identity 组、Shared VPC/NCC 互联、Security Command Center 合规、Folder 委派与 Shared VPC 接入。详见 [docs/enterprise-scenarios.md](docs/enterprise-scenarios.md)。

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
