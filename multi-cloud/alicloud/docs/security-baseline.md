# Alibaba Cloud Security Baseline

## 1. 解决的企业问题

企业账号越多，安全问题越容易从“单账号配置错误”升级为“组织级风险”。
阿里云安全基线分两层：

- 账号内 RAM 基线：密码、MFA、AccessKey 管控。
- 组织级管控策略：在 Resource Directory 层拒绝高危操作。

## 2. 使用的云原生服务

- **RAM password policy / security preference**：账号级身份安全配置。
- **Resource Directory Control Policy**：组织级 deny guardrails。

## 3. Terraform 模块边界

由 [`modules/security`](../modules/security) 实现：

- **负责**：RAM 密码策略、安全偏好、MFA、用户自管 AccessKey 开关。
- **不负责**：组织级管控策略、审计日志与运行时合规检测。

由 [`modules/control-policies`](../modules/control-policies) 实现：

- **负责**：创建 Resource Directory 管控策略，校验 JSON 策略文档，附加到 root/folder/account 目标。
- **不负责**：设计组织层级、启用 Resource Directory、替代 Cloud Config。

## 4. 推荐护栏

| 护栏 | 目标 |
|---|---|
| 禁止关闭 ActionTrail / 删除审计 trail | 保护集中审计 |
| 禁止删除日志归档 OSS/SLS 资源 | 保护证据链 |
| 禁止创建长期 AccessKey | 推动 SSO/OIDC/STS |
| 限制允许地域 | 降低数据驻留与合规风险 |
| 禁止公网暴露高危端口 | 降低入侵面 |

## 5. 测试

静态检查（无需云账号）：`fmt` + `init -backend=false` + `validate`，见
[../tests/README.md](../tests/README.md)。`plan` 需 sandbox 管理账号凭证。

## 6. 输入、输出与依赖

- `modules/security` 输入：密码长度、密码有效期、密码复用次数、登录失败锁定次数、MFA 登录要求、用户自管 AccessKey 开关、会话时长。
- `modules/security` 输出：`password_policy_id`、`security_preference_id`。
- `modules/control-policies` 输入：`policies`、`attachments`、`common_tags`。
- `modules/control-policies` 输出：`policy_ids`、`attachment_ids`。
- 依赖：Resource Directory 已启用；Control Policy 已启用；调用方具备 ResourceManager 与 RAM 安全配置权限。

## 7. 回滚

- 先从目标 folder/account 解绑管控策略，再删除策略。
- 对生产 folder 推出 deny 策略前，先在 sandbox 验证常见运维与 break-glass 流程。

## 8. 常见故障排查

| 现象 | 可能原因 | 处理 |
|---|---|---|
| 管控策略创建失败 | Resource Directory Control Policy 未启用 | 先在管理账号启用 Control Policy |
| 解绑/删除失败 | 策略仍附加在 folder/account | 先删除 attachment，再删除 policy |
| 业务部署被拒绝 | deny 策略命中正常运维动作 | 在 sandbox 复现，收敛 Action/Condition 后再推广 |
| RAM 安全配置失败 | 调用方权限不足 | 使用管理账号安全基线角色执行 |
