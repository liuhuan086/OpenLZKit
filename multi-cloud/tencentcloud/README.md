# Tencent Cloud Landing Zone

## 定位

本目录是 OpenLZKit 针对 Tencent Cloud 的独立 Landing Zone 设计与实现目录。它遵循 Tencent Cloud 原生治理模型，不强行套用其他云的账号、网络或权限结构。

## 原生治理模型

- 推荐基础：Control Center / Organization / CAM
- 关键能力：Organization, core accounts, CAM roles, finance, security rules, audit, VPC

## 目录

```text
tencentcloud/
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
| `00-bootstrap` | [`live/00-bootstrap`](live/00-bootstrap) | ✅ 已实现（COS state 桶 + CAM CI 角色） |
| `10-org` | [`modules/org`](modules/org), [`modules/account-factory`](modules/account-factory) | ✅ 已实现（组织节点层级 + 成员账号工厂 FP-1，创建默认关闭） |
| `20-identity` | [`modules/identity`](modules/identity) | ✅ 已实现（CAM 自定义策略 + 角色 + 附加） |
| 其他层 | — | 🚧 待实现（见路线图） |

## 企业级深化

与阿里云 / AWS / Azure / GCP 保持同一套治理标准，按腾讯云原生模型深化多账号（成员账号工厂）、组织护栏（管控策略）、业务部门、跨账号访问、CAM 用户组 + SSO、CCN 互联、CloudAudit + CSIP 合规、组织委派与 Share Unit 共享。详见 [docs/enterprise-scenarios.md](docs/enterprise-scenarios.md)。

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
