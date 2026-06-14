# 测试策略

## 测试分层

| 层级 | 工具 | 是否需要云账号 | 目标 |
|---|---|---|---|
| 格式测试 | terraform fmt | 否 | 统一代码风格 |
| 语法测试 | terraform validate | 否/部分需要 provider init | 检查语法和变量 |
| 静态扫描 | TFLint | 否 | 检查 provider/resource 规则 |
| 安全扫描 | Checkov/tfsec | 否 | 检查高危配置 |
| 策略测试 | OPA/Conftest | 否 | 检查自定义治理规则 |
| Plan 测试 | terraform plan | 是 | 验证真实云 API 与依赖 |
| 集成测试 | Terratest/脚本 | 是 | 创建并验证资源 |
| 冒烟测试 | CLI/API | 是 | 验证关键输出可用 |
| Drift 测试 | terraform plan -detailed-exitcode | 是 | 检查手工漂移 |

## PR 必过门禁

- fmt。
- validate。
- tflint。
- checkov/tfsec。
- conftest。
- README 是否更新。
- examples 是否可初始化。
- 变量是否有描述。
- 输出是否有描述。
- 文档链接是否有效。
- 示例值是否为明显假值，不能包含真实账号、租户、UIN、项目或个人信息。
- 对 state 地址迁移、资源替换和高风险默认值有说明。

## 生产发布门禁

- Plan artifact 人工审核。
- 安全角色审核。
- 变更窗口确认。
- 回滚方案确认。
- 审计日志开启确认。
- 目标账号/订阅/项目配额和区域已确认。
- 变更影响的 owner 已确认。
- 关键日志、告警和成本标签在 sandbox 验证。
- 如有策略例外，必须包含 owner、reason、expiry_date 和补偿控制。

## 文档测试

文档变更也要测试：

- 本地 Markdown 链接检查。
- `TODO` / `TBD` 扫描，确认不是权威页残留。
- 命令示例使用假值和相对正确路径。
- 每个云的 `docs/` 至少覆盖 account、identity、network、security、operations 和 enterprise-scenarios。
- 模块 README 的输入、输出、安全注意事项与 `variables.tf` / `outputs.tf` 保持一致。

## 回归策略

小文档修复只需链接检查和敏感信息扫描。涉及模块边界、状态迁移或云服务能力的文档变更，需要同时跑对应 Terraform validate，并在 PR 描述中说明是否需要 ADR。
