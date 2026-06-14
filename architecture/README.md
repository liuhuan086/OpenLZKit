# 架构

OpenLZKit 的架构文档用于回答三个问题：

1. 为什么五朵云要各自独立实现。
2. Landing Zone 的共享治理标准如何贯穿文档、IaC、CI/CD、测试和运维。
3. 哪些设计选择会影响 state、安全边界、云厂商原生模型和后续演进。

## 目录

| 路径 | 内容 |
|---|---|
| [adr/](adr/) | 架构决策记录。记录不可随意改动的取舍、约束和后果。 |
| [diagrams/](diagrams/) | 架构图和 Mermaid 图谱。用于快速解释跨云治理、部署流程、身份、网络和日志链路。 |

## 架构原则

- **云原生优先**：AWS、阿里云、腾讯云、Azure、GCP 使用各自原生组织、身份、网络、安全和日志能力。
- **共享标准，不共享错误抽象**：共享目录结构、命名、测试、文档、CI/CD、标签和验收标准；不做统一资源模型。
- **文档与 IaC 同等重要**：每个模块都必须能从 README、设计文档、runbook 和测试用例追溯到实现。
- **安全默认开启**：短期凭证、最小权限、集中审计、策略即代码、state 隔离和强制标签是基线。
- **渐进式落地**：先静态验证，再 sandbox apply，再生产推广；策略从低风险 scope 向高风险 scope 推进。

## 什么时候新增 ADR

以下变更需要新增或更新 ADR：

- 改变云原生模型选择，例如从 Azure Hub-Spoke 改为 Virtual WAN-first。
- 改变 Terraform state 拆分、后端、锁或迁移策略。
- 改变生产默认安全策略、凭证模型或日志留存模型。
- 引入跨云统一抽象、代码生成器或工具层。
- 会导致已有资源地址迁移、强制替换或运维流程变化的模块设计。

小范围文档修复、README 示例更新、变量描述补充不需要 ADR。

## 阅读建议

1. 先读 [ADR-0001](adr/ADR-0001-cloud-specific-design-over-shared-abstraction.md)，理解为什么不做 universal multi-cloud module。
2. 再读 [ADR-0002](adr/ADR-0002-layered-live-stacks-and-state-isolation.md)，理解 live stack 和 state 边界。
3. 再读 [ADR-0003](adr/ADR-0003-security-defaults-and-short-lived-credentials.md)，理解安全默认值。
4. 最后看 [diagrams/](diagrams/) 的图谱，把设计映射到实际目录和实施流程。
