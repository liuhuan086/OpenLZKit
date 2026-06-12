# AWS Identity Model

## 目标

AWS Landing Zone 的人员访问应通过 IAM Identity Center 获得短期凭证，按组分配 permission set 到账号，而不是在成员账号内创建 IAM user 或长期 access key。机器访问由 FP-4 的 STS/OIDC 跨账号角色承载；账号内 IAM 基线用于账号别名、应急密码策略、权限边界和客户托管策略。

## 云原生服务

- IAM Identity Center Permission Set：定义人员访问权限包。
- IAM Identity Center Account Assignment：把 permission set 分配给账号中的 group 或 user。
- Identity Store Group/User/Membership：可选创建本地身份对象；生产通常接入外部 IdP 同步。
- IAM Managed Policy / Inline Policy：permission set 的权限来源。
- IAM Account Alias / Password Policy：成员账号可读标识与应急 IAM 用户密码约束。
- IAM Permission Boundary：约束成员账号内工作负载角色和例外角色的最大权限。

## 模块边界

账号 IAM 基线由 [`modules/identity`](../modules/identity) 实现：

- **负责**：账号 alias、账号密码策略、permission boundary policy、客户托管 policy。
- **不负责**：创建 IAM user、长期 access key、人员 SSO 分配、跨账号机器角色。

人员 SSO 由 [`modules/identity-center`](../modules/identity-center) 实现：

- **负责**：创建 permission set、managed policy attachment、inline policy、可选 group/user/membership、account assignment。
- **不负责**：启用 IAM Identity Center、接入外部 IdP、创建 AWS 账号、创建跨账号机器角色。

下游协作：

- `modules/account-factory` 输出账号 id，作为 `assignments.target_id`。
- `modules/department` 输出部门归属和标签，帮助定义 group-to-account 分配矩阵。
- `modules/cross-account-access` 继续承载 CI/CD、日志、安全自动化等机器访问。

## 推荐 Permission Set

| key | 用途 | 权限建议 |
|---|---|---|
| `security_audit` | 安全团队只读审计所有账号 | `SecurityAudit` + 必要只读补充 |
| `platform_admin` | 平台团队管理共享服务/网络账号 | 最小自定义管理策略，避免全局 `AdministratorAccess` 常态化 |
| `workload_readonly` | 业务团队只读排障 | `ReadOnlyAccess` + 禁止 access key 操作的 inline deny |
| `workload_poweruser` | 非生产业务操作 | 受 SCP、permission boundary 和审批流程限制 |
| `break_glass` | 应急访问 | 单独审批、强 MFA、短会话、强审计 |

## 输入、输出与依赖

主要输入：

- `instance_arn`：IAM Identity Center instance ARN。
- `identity_store_id`：Identity Store id。
- `permission_sets`：permission set map。
- `assignments`：账号分配 map，显式指定 principal 和 target account。
- `groups`、`users`、`group_memberships`：可选本地 Identity Store 对象。
- `permission_boundaries`：账号内权限边界 policy map。
- `managed_policies`：账号内客户托管 policy map。

主要输出：

- `permission_boundary_arns`
- `managed_policy_arns`
- `permission_set_arns`
- `group_ids`
- `user_ids`
- `assignment_ids`

依赖：

- IAM Identity Center 已启用。
- 如使用外部 IdP，同步后的 group/user id 已可用。
- 调用身份具备 `ssoadmin` 和 `identitystore` 权限。

## 测试

静态检查：

```bash
terraform -chdir=multi-cloud/aws/examples/identity-center fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/identity-center init -backend=false
terraform -chdir=multi-cloud/aws/examples/identity-center validate

terraform -chdir=multi-cloud/aws/live/25-sso fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/25-sso init -backend=false
terraform -chdir=multi-cloud/aws/live/25-sso validate

terraform -chdir=multi-cloud/aws/examples/identity fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/identity init -backend=false
terraform -chdir=multi-cloud/aws/examples/identity validate

terraform -chdir=multi-cloud/aws/live/20-identity fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/20-identity init -backend=false
terraform -chdir=multi-cloud/aws/live/20-identity validate
```

集成验证：

- 在 sandbox Identity Center instance 中创建一个测试 group 和 permission set。
- 只分配到 sandbox account，确认登录后权限与 session duration 符合预期。
- 验证离职/转岗流程：从 group 移除后账号访问消失。

## 回滚

- 先删除 account assignment。
- 再删除 permission set inline/managed policy attachment。
- 最后删除 permission set、group membership、group/user。
- 对外部 IdP 同步对象，不在 Terraform 内删除源身份。

## 常见故障

| 现象 | 排查 |
|---|---|
| Assignment 创建失败 | 检查 `principal_id`、`principal_type`、`target_id` 是否真实存在。 |
| Permission set 不生效 | 等待 SSO provisioning 完成，并检查账号是否受 SCP 限制。 |
| 用户看不到账号 | 确认用户在对应 group 中，且 assignment target account 正确。 |
| Inline policy 校验失败 | 使用 `jsonencode` 生成 JSON，避免手写语法错误。 |
