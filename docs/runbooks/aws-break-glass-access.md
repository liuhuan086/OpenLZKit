# AWS Break-Glass Access

## 目的

Break-glass 只用于 IAM Identity Center、OIDC、SCP 或网络控制失效时的紧急恢复，不用于日常 apply。

## 设计要求

- 角色名称、trust principal 和权限边界必须被文档化。
- 访问必须短期、可审计、需要审批和事后复盘。
- 不在仓库保存任何长期 access key。
- SCP 推广前必须确认 break-glass path 不会被误拦截。

## 操作流程

1. 事故负责人记录原因、影响账号、预期操作和过期时间。
2. 安全负责人审批临时访问。
3. 使用 IAM Identity Center 或受控 federation 获取短期凭证。
4. 只执行恢复所需操作，例如 detach 错误 SCP、修复 role trust、恢复 state lock。
5. 保存 CloudTrail 脱敏摘要。
6. 撤销临时访问并复盘 root cause。

## 禁止事项

- 禁止创建长期 IAM user access key。
- 禁止用 management account 承载业务资源。
- 禁止扩大到不相关 OU/account。
- 禁止绕过 Git/PR 长期保留手工变更。
