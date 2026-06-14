# AWS Landing Zone Design

AWS Landing Zone 使用 AWS Organizations / OU / Account / IAM Identity Center / SCP / Transit Gateway / CloudTrail / Config / Security Hub 等原生能力。AWS 账号是主要隔离边界，OU 是策略继承边界，管理账号不承载业务资源。

## 阅读顺序

1. [account-model.md](account-model.md)
2. [identity-model.md](identity-model.md)
3. [network-model.md](network-model.md)
4. [security-baseline.md](security-baseline.md)
5. [operations-runbook.md](operations-runbook.md)
6. [enterprise-scenarios.md](enterprise-scenarios.md)

## 目标结构

```text
management account
├── security
│   ├── log-archive
│   └── security-tooling
├── infrastructure
│   ├── network
│   └── shared-services
├── workloads
│   ├── prod
│   └── nonprod
└── sandbox
```

## 设计原则

- 账号按安全、环境、业务和成本边界拆分，不按临时组织架构硬拆。
- 人员访问走 IAM Identity Center，机器访问走 OIDC/STS AssumeRole。
- SCP 和 Tag Policy 先在 sandbox OU 验证，再推广到生产 OU/root。
- 日志进入专用 log archive account，启用版本化、加密和保留策略。
- 网络集中在 network account，用 Transit Gateway 明确 route table、association 和 propagation。

## 实施门禁

- `00-bootstrap` 先建立远程 state 和 CI OIDC。
- 每个 live stack 独立 state，生产 apply 需要审批。
- `terraform fmt`、`validate`、TFLint、Checkov、Conftest 是 PR 基线。
- 任何会迁移 state 地址或替换生产资源的变更必须有 ADR 或迁移说明。
