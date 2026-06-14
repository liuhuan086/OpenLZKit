# ADR-0001: 使用云原生独立设计，而不是统一多云抽象

## 状态

Accepted（已接受）

## 背景

OpenLZKit 覆盖阿里云、AWS、腾讯云、Azure 和 Google Cloud。五朵云的治理原语不同：AWS 有 Organizations / OU / Account，Azure 有 Management Group / Subscription，GCP 有 Organization / Folder / Project，阿里云和腾讯云也各自有资源目录、组织节点、成员账号、RAM/CAM、管控策略、网络与日志服务。

## 决策

OpenLZKit 不创建一个覆盖所有云的统一 Terraform 抽象。每朵云保留独立目录、模块、live stack 和设计文档。项目共享的是文档、测试、CI/CD、命名、标签、验收和贡献流程等标准，而不是共享一套资源模型。

## 影响

正向影响：

- 保留每朵云的原生最佳实践。
- 面试、企业评审和咨询交付时更容易解释设计边界。
- 避免把云厂商差异隐藏进有泄漏风险的抽象层。
- 每朵云可以按各自 provider 和治理模型独立演进。

负向影响：

- 需要维护更多目录和文档。
- 不同云之间会存在概念性重复。
- 跨云报告必须显式做概念映射，不能依赖单一 Terraform 资源模型。

这个取舍是可接受的，因为 Landing Zone 本质是治理工程，必须尊重云厂商原生能力和边界。

## 后续决策

- [ADR-0002](ADR-0002-layered-live-stacks-and-state-isolation.md) 定义 live stack 和 state 的隔离方式。
- [ADR-0003](ADR-0003-security-defaults-and-short-lived-credentials.md) 定义安全默认值和短期凭证原则。
- [ADR-0004](ADR-0004-documentation-and-policy-gates-as-release-contract.md) 定义文档与策略门禁作为发布契约。
