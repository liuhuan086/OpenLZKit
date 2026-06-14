# Tencent Cloud Landing Zone Design

Tencent Cloud Landing Zone 使用腾讯云组织 / 组织节点 / 成员账号 / CAM / 管控策略 / VPC / CCN / CloudAudit / CLS / CSIP / 分账标签等原生能力。组织节点是策略继承边界，成员账号是资源、账单和权限边界。

## 阅读顺序

1. [account-model.md](account-model.md)
2. [identity-model.md](identity-model.md)
3. [network-model.md](network-model.md)
4. [security-baseline.md](security-baseline.md)
5. [operations-runbook.md](operations-runbook.md)
6. [enterprise-scenarios.md](enterprise-scenarios.md)

## 目标结构

```text
root
├── platform
│   ├── security
│   ├── logging
│   └── network
├── workloads
│   ├── prod
│   └── nonprod
├── sandbox
└── suspended
```

## 设计原则

- 主账号只做组织和应急治理，业务资源进入成员账号。
- 人员访问走 CAM 组/SSO，自动化走 STS 临时凭证。
- 管控策略先在 sandbox 节点验证，再推广到生产节点。
- CCN 挂载必须显式声明，sandbox 不接入生产路由域。
- CloudAudit 和 CLS 是上线前硬门禁。

## 实施门禁

- 成员账号创建涉及实名、计费和联系人信息，默认不自动创建真实账号。
- 长期 SecretKey 不能作为 CI/CD 默认方式。
- 任何跨账号 trust document 必须限定来源 UIN 和条件。
- 管控策略、日志和分账标签在 sandbox 验证后再推广。
