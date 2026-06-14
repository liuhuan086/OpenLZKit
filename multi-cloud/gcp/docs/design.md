# Google Cloud Landing Zone Design

Google Cloud Landing Zone 使用 Organization / Folders / Projects / Cloud Identity / IAM / Organization Policy / Shared VPC / Cloud Logging / Security Command Center 等原生能力。Folder 是策略继承边界，Project 是资源、API、配额、IAM 和账单边界。

## 阅读顺序

1. [account-model.md](account-model.md)
2. [identity-model.md](identity-model.md)
3. [network-model.md](network-model.md)
4. [security-baseline.md](security-baseline.md)
5. [operations-runbook.md](operations-runbook.md)
6. [enterprise-scenarios.md](enterprise-scenarios.md)

## 目标结构

```text
organizations/<org-id>
├── folders/platform
│   ├── security
│   ├── logging
│   └── network
├── folders/workloads
│   ├── prod
│   └── nonprod
├── folders/sandbox
└── folders/decommissioned
```

## 设计原则

- Project factory 默认不创建真实 project，必须显式传入 billing 和 labels。
- 人员访问走 Cloud Identity group；自动化走 Workload Identity Federation。
- Org Policy 禁止 service account key、默认网络、未批准区域和公开存储。
- Shared VPC host/service project 严格区分 prod、nonprod 和 sandbox。
- Cloud Audit Logs 和 SCC findings 进入集中日志/安全 project。

## 实施门禁

- `00-bootstrap` 创建 GCS state 和 WIF 基础，真实 apply 需要 seed project。
- Project id 全局唯一且不可复用，命名前必须评审。
- Org Policy 先在 folder 层验证，再推广到 organization。
- 生产禁止下载 service account key；发现 key 视为安全事件。
