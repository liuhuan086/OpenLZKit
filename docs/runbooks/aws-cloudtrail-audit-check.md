# AWS CloudTrail Audit Check

## 目标

确认 Landing Zone 关键变更被 CloudTrail 捕获，并写入受保护的 log archive 路径。

## 检查项

| 项 | 期望 |
|---|---|
| Organization trail | enabled |
| Multi-region trail | enabled unless sandbox explicitly scoped |
| Log bucket | versioning、encryption、public access block enabled |
| Object Lock / retention | 按 sandbox 或生产策略启用 |
| KMS key | key policy 允许 CloudTrail 写入，限制非授权读取 |
| Management events | read/write events enabled |
| Data events | 对关键 S3/Lambda 按需开启 |

## 证据

- CloudTrail trail 摘要。
- log bucket control 摘要。
- 最近一次 apply 的 CloudTrail event 类型和时间窗口。
- Security Hub / Config 中与 CloudTrail 相关规则的状态。

不要提交真实 account id、user ARN、source IP、bucket 唯一名或事件原文。
