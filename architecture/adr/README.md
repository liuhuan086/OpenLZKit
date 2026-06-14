# 架构决策记录

ADR 用于记录 OpenLZKit 中影响长期维护和企业落地的设计取舍。新增 ADR 时使用递增编号；文件名可以保留英文短名以便稳定链接，正文以中文为主。内容至少包含状态、背景、决策、影响。

## 索引

| ADR | 状态 | 决策 |
|---|---|---|
| [ADR-0001](ADR-0001-cloud-specific-design-over-shared-abstraction.md) | Accepted（已接受） | 每朵云独立设计，不做万能 multi-cloud Terraform 抽象。 |
| [ADR-0002](ADR-0002-layered-live-stacks-and-state-isolation.md) | Accepted（已接受） | live stack 按阶段拆分，Terraform state 按云、层、环境隔离。 |
| [ADR-0003](ADR-0003-security-defaults-and-short-lived-credentials.md) | Accepted（已接受） | 默认使用短期凭证、最小权限、集中审计和显式 opt-in 高风险操作。 |
| [ADR-0004](ADR-0004-documentation-and-policy-gates-as-release-contract.md) | Accepted（已接受） | 文档完整性、策略即代码和 CI 门禁是发布契约的一部分。 |

## ADR 模板

```markdown
# ADR-XXXX: 标题

## 状态

Proposed（提议） | Accepted（已接受） | Superseded（已废弃）

## 背景

这个决策要解决什么问题或取舍？

## 决策

选择的方向是什么？

## 影响

正负影响，包括迁移和测试影响。
```
