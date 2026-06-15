# AWS Account Vending Failure

## 常见原因

- Organizations account creation quota 或并发限制。
- email 已被 AWS account 使用。
- Control Tower/AFT 与 Terraform 直接创建账号的 ownership 不清。
- SCP 或 management account 权限阻止创建。
- 账号创建成功但 move OU、tag 或后续 baseline 失败。

## 处理步骤

1. 停止继续 apply 依赖该账号的后续 stack。
2. 通过 Organizations 控制台或 CLI 确认 create account request 状态。
3. 如果账号已创建，记录脱敏 account id，并决定 import、move、关闭或人工清理。
4. 如果 email 冲突，改用 `example.com` 域下新的假值或真实企业受控邮箱。
5. 如果 OU move 失败，先检查 SCP 和 Organizations delegated permissions。
6. 更新 account request PR，附上失败原因和下一步。

## 防护

- `modules/account-factory` 默认空 map，避免误创建真实账号。
- 账号创建必须显式 opt-in，并走人工审批。
- Demo 和测试使用 `example.com` 邮箱，不使用个人邮箱。
- 真实执行证据只提交脱敏摘要。
