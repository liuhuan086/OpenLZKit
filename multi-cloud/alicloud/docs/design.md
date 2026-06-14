# Alibaba Cloud Landing Zone Design

Alibaba Cloud Landing Zone 使用 Resource Directory / Folder / Account / RAM / CloudSSO / ActionTrail / Cloud Config / CEN-TR / SLS / OSS 等原生能力。资源目录管理账号只做治理入口，不承载业务资源。

## 阅读顺序

1. [account-model.md](account-model.md)
2. [identity-model.md](identity-model.md)
3. [sso-model.md](sso-model.md)
4. [network-model.md](network-model.md)
5. [security-baseline.md](security-baseline.md)
6. [operations-runbook.md](operations-runbook.md)
7. [enterprise-scenarios.md](enterprise-scenarios.md)

## 目标结构

```text
Resource Directory Root
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

- 成员账号按环境和职责隔离；账号工厂默认空 map，避免误创建真实账号。
- 人员访问走 CloudSSO，自动化走 OIDC/STS AssumeRole。
- 管控策略、标签策略和 Cloud Config 共同构成安全基线。
- ActionTrail 和关键服务日志进入专用日志账号的 SLS/OSS。
- CEN/TR 接入必须明确路由域，sandbox 不接入生产路由域。

## 实施门禁

- `00-bootstrap` 启用 Resource Directory 和远程 state，生产前确认账号级影响。
- 每个 live stack 独立 state。
- 任何 AccessKey 出现在代码、文档或 CI secret 中都视为阻塞问题。
- 策略先挂 sandbox folder 验证，再推广到 nonprod/prod/root。
