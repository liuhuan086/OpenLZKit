# ADR-0004: 将文档与策略门禁视为发布契约

## 状态

Accepted（已接受）

## 背景

OpenLZKit 是文档优先、IaC 优先的项目。Landing Zone Blueprint 的价值不只是 Terraform 能 validate，还在于平台团队能理解边界、apply 顺序、安全假设、测试方式、回滚步骤和常见故障模式。

如果没有文档和策略门禁，一个模块可能看起来完整，但在真实企业推广中仍然不安全或不可用。

## 决策

OpenLZKit 将文档完整性和策略门禁视为发布契约的一部分。任何有实际意义的模块或 live stack 变更，都必须同步维护：

- 模块 README。
- Variables 和 outputs。
- Examples 或 live stack 用法。
- 云内设计或 model 文档。
- 安全注意事项和回滚/runbook 指引。
- 适用场景下的静态检查和 policy-as-code。

CI 门禁保持为：

- `terraform fmt`
- `terraform validate`
- TFLint
- Checkov
- Conftest policy tests

即使尚未全部自动化进 CI，发布前仍应执行文档检查，例如内部链接校验、未完成标记扫描、敏感值扫描。

## 影响

正向影响：

- 新贡献者可以按文档扩展云，不需要猜实现模型。
- Reviewers 能判断变更是否可部署，而不只是语法是否正确。
- Policy-as-code 将项目治理规则变成可执行检查。
- 文档漂移会被视为发布风险。

负向影响：

- 小实现变更也可能需要更新 README 或 runbook。
- Review 需要投入更多精力检查示例、测试用例和故障模式。
- 部分云内策略需要 provider-specific Rego，而不是一条共享规则。

## 发布规则

- 缺少 README、变量、输出、示例和安全注意事项的模块不完整。
- 没有明确警告或 opt-in 的高风险默认值不完整。
- 缺少回滚指引或 state 边界说明的 stack 不完整。
- 纯文档变更也需要链接检查和敏感值检查。
