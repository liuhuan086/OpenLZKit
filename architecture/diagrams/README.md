# 架构图

本目录存放 OpenLZKit 的 diagram-as-code 架构视图。当前使用 Mermaid，因为它能在 GitHub 中渲染，也方便在 PR 中 review。

## 图谱索引

| Diagram | Purpose |
|---|---|
| [multi-cloud-governance-map.md](multi-cloud-governance-map.md) | 多云治理能力域与云原生实现映射。 |
| [live-stack-flow.md](live-stack-flow.md) | Terraform live stack 顺序和 state 边界。 |
| [identity-access-flow.md](identity-access-flow.md) | 人员、CI/CD 和工作负载身份访问链路。 |
| [network-topologies.md](network-topologies.md) | Hub-Spoke、Shared VPC、CCN/CEN 等网络模式。 |
| [logging-audit-flow.md](logging-audit-flow.md) | 审计和日志集中归档与安全分析链路。 |

## 维护规则

- 图保持概念层；provider-specific 资源名放在模块文档中。
- 使用云原生标签，不用单一通用账号抽象掩盖差异。
- 改变 stack 顺序、身份模型、日志路径或网络拓扑时同步更新图谱。
- 如果图谱变化体现了架构取舍，应新增或更新 ADR。
