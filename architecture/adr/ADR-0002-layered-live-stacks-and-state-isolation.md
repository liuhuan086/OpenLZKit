# ADR-0002: 使用分层 Live Stack 和隔离 Terraform State

## 状态

Accepted（已接受）

## 背景

Landing Zone 资源的影响范围不同。Bootstrap state 存储、组织结构、身份、网络、安全策略、日志、FinOps 和工作负载接入不应该共享同一个 Terraform state。单一 state 会让小变更变得高风险，也会拖慢评审并增加回滚难度。

仓库已经把每朵云组织成有顺序的 live stack：

```text
00-bootstrap
10-org
15-departments
20-identity
24-cross-account-access
25-sso
30-network
35-connectivity
40-security
45-compliance
50-logging
55-delegation
60-finops
70-workload-onboarding
```

## 决策

OpenLZKit 保持 live stack 分层，并为每个层级维护独立 state。State 按云、stack 和环境隔离。Bootstrap 最先运行，创建远程后端或后续 stack 所需的身份。后续 stack 通过显式变量或文档化 handoff 消费输出，而不是隐式读取任意 remote state。

每个 stack 必须具备：

- 清晰的职责边界。
- 独立 backend key 或等价 state 路径。
- README 中说明 init、validate、plan 和评审方式。
- 保守的默认输入，避免在未显式启用时创建真实账号、项目、订阅或高成本资源。

## 影响

正向影响：

- 限制策略、网络和身份变更的爆炸半径。
- 让 plan 更小、更容易评审和批准。
- 支持团队按 sandbox、nonprod、prod 逐步推广。
- 把 state bucket、CI 身份等敏感平台资源与工作负载接入隔离。

负向影响：

- 运维者必须理解 stack 顺序和 handoff 值。
- 部分 ID 需要在 stack 之间手工传递或通过受控输出流程传递。
- 需要维护更多 backend key 和文档。

## 运维规则

- 不要因为同属一朵云就把无关 stack 变更合并在一起。
- 没有迁移计划时，不要在 stack 之间移动资源；可行时应提供 Terraform `moved` 块或 import 说明。
- state 迁移或 backend 重设计需要新增 ADR 或更新本 ADR。
