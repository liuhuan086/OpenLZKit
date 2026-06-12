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

## 生产发布门禁

- Plan artifact 人工审核。
- 安全角色审核。
- 变更窗口确认。
- 回滚方案确认。
- 审计日志开启确认。
