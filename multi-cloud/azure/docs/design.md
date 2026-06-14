# Azure Landing Zone Design

Azure Landing Zone 使用 Management Groups / Subscriptions / Microsoft Entra ID / RBAC / Azure Policy / Log Analytics / Defender for Cloud / Hub-Spoke 或 Virtual WAN 等原生能力。管理组是策略继承边界，订阅是资源、账单和配额边界。

## 阅读顺序

1. [account-model.md](account-model.md)
2. [identity-model.md](identity-model.md)
3. [network-model.md](network-model.md)
4. [security-baseline.md](security-baseline.md)
5. [operations-runbook.md](operations-runbook.md)
6. [enterprise-scenarios.md](enterprise-scenarios.md)

## 目标结构

```text
Tenant Root Group
├── Platform
│   ├── Identity
│   ├── Management
│   └── Connectivity
├── LandingZones
│   ├── Corp
│   └── Online
├── Sandbox
└── Decommissioned
```

## 设计原则

- 平台订阅承载共享服务，应用订阅通过 vending 流程接入。
- 人员访问走 Entra group + RBAC/PIM，自动化走 federated credential。
- Azure Policy 在管理组层前移，exemption 必须有 owner、reason、expiry。
- Activity Log、诊断日志和 Defender findings 进入集中 Log Analytics/归档。
- Hub-Spoke 和 Private DNS/Private Endpoint 同步设计，避免只建网络不解 DNS。

## 实施门禁

- `00-bootstrap` 创建 state 存储和 OIDC 基础，真实 apply 需要企业订阅权限。
- 订阅售卖默认不自动购买真实订阅。
- 生产 apply 身份和 plan 身份分离。
- Policy 在 sandbox 管理组验证后再推广。
