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
