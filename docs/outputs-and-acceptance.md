# 输出物与验收标准

## 项目级输出物

- README.md。
- PRD。
- prompts.md。
- 企业设计原则。
- 多云策略文档。
- 从 0 到 1 实施文档。
- 跨账号/跨服务访问说明。
- Demo Mode：业务申请、预期组织/网络/控制和无云账号可读的演示路径。
- Sandbox apply evidence report：真实执行时只提交脱敏摘要。
- Control mapping：控制目标、云原生实现、Rego 检查和证据映射。
- 测试策略。
- 参考资料。
- LICENSE、CONTRIBUTING、SECURITY、CODE_OF_CONDUCT。

## 每朵云输出物

- 云级 README。
- 账号/订阅/项目模型。
- 身份权限模型。
- 网络模型。
- 安全基线。
- 日志审计设计。
- FinOps 设计。
- Terraform modules。
- live stacks。
- policies。
- examples。
- tests。
- operations runbook。

## 验收标准

1. 文档完整：新人能根据文档理解目标和边界。
2. 目录清晰：任意云都能独立开发、测试和发布。
3. 安全合规：无硬编码密钥，无默认高危配置。
4. 测试可跑：本地测试和云上测试边界清晰。
5. 简历可讲：项目能讲出真实企业问题和解决方案。
6. 商业化可延展：能从开源模板扩展到咨询、培训、审计或托管平台。

## 文档质量标准

- 每个权威文档只回答一个主题，避免同一规则散落多处。
- 概念文档解释“为什么”，设计文档解释“怎么设计”，模块 README 解释“怎么使用”，runbook 解释“出事怎么处理”。
- 云厂商差异必须显式写出来；不能用通用词掩盖账号、订阅、项目、Folder、OU、管理组的差异。
- 所有命令、账号、邮箱、仓库、UIN、租户和订阅示例必须使用明显假值。
- 高风险默认值必须标注风险，并尽量默认关闭或空 map。
- 涉及 state 迁移、资源替换、策略推广、日志留存和 break-glass 的内容必须给出回滚或复核步骤。

## 实施成熟度验收

| 成熟度 | 验收重点 |
|---|---|
| L0 文档包 | 目录、概念、设计、runbook 和测试策略完整。 |
| L1 静态可验证 | Terraform fmt/validate、policy tests 和文档链接检查通过。 |
| L2 Sandbox 可运行 | 在 sandbox 账号/订阅/项目完成最小 apply 和回滚演练。 |
| L3 生产可控 | 有审批、plan artifact、日志、告警、例外、break-glass 和成本归因。 |
| L4 持续治理 | 定期 drift、权限复核、策略例外清理、成本优化和架构复盘。 |

## 证据链验收

| 证据 | L1 静态可验证 | L2 Sandbox 可运行 |
|---|---|---|
| Terraform | fmt/validate 通过 | plan/apply/destroy 或受控 rollback 摘要 |
| Policy-as-code | Rego unit tests / Conftest 输出 | 基于脱敏 plan JSON 的 Conftest 输出 |
| 云上资源 | README 与模块说明完整 | CLI/API/控制台脱敏摘要 |
| 审计 | runbook 描述审计路径 | CloudTrail/ActionTrail/Activity Log 等脱敏事件摘要 |
| 成本 | 标签和预算设计完整 | budget/CUR/export 脱敏摘要 |
| 回滚 | 文档说明 | 实际演练记录或明确不能删除的原因 |
