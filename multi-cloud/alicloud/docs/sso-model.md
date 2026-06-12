# Alibaba Cloud CloudSSO Model

## 1. 解决的企业问题

企业多账号环境不能在每个成员账号里创建 RAM 用户。CloudSSO 把人员身份、
权限配置和账号访问分配集中管理，让人员通过临时会话进入目标账号。

## 2. 使用的云原生服务

- **CloudSSO Directory**：人员身份目录与登录入口。
- **CloudSSO Group/User**：用户和组；生产环境优先 SCIM/外部 IdP。
- **Access Configuration**：权限配置，类似 permission set。
- **Access Assignment**：把用户/组/主体分配到目标账号。
- **Access Configuration Provisioning**：把权限配置下发到目标账号。

## 3. Terraform 模块边界

由 [`modules/sso`](../modules/sso) 实现：

- **负责**：CloudSSO directory、groups、可选 local users、group memberships、access configurations、assignments、provisioning。
- **不负责**：企业 IdP 侧用户生命周期、密码托管、账号创建、自定义 RAM policy 全生命周期。

## 4. 推荐访问模型

| 角色 | CloudSSO group | Access configuration | 目标 |
|---|---|---|---|
| 平台管理员 | `platform-admins` | PlatformAdmin | 管理账号/平台账号 |
| 安全审计 | `security-auditors` | SecurityAudit | 全部成员账号 |
| 部门管理员 | `<dept>-admins` | DepartmentAdmin | 部门账号 |
| 应用开发 | `<app>-developers` | WorkloadDeveloper | 工作负载账号 |

## 5. 输入、输出与依赖

- 输入：`directory_id`/`create_directory`、`groups`、`users`、`access_configurations`、`assignments`、`provisionings`。
- 输出：`directory_id`、`group_ids`、`user_ids`、`access_configuration_ids`、`assignment_ids`。
- 依赖：Resource Directory 与目标账号已存在；调用方具备 CloudSSO 管理权限。

## 6. 测试

静态检查（无需云账号）：`fmt` + `init -backend=false` + `validate`，见
[../tests/README.md](../tests/README.md)。`plan` 需 CloudSSO 管理权限。

## 7. 回滚

- 先删除 account assignment。
- 再删除 access configuration provisioning。
- 删除 access configuration、group memberships、groups/users。
- 最后按需删除 CloudSSO directory。

## 8. 常见故障排查

| 现象 | 可能原因 | 处理 |
|---|---|---|
| assignment 失败 | target account 不存在或 principal id 不正确 | 使用账号工厂输出和 `group_ids`/`user_ids` |
| 权限配置未生效 | 未 provisioning 到目标账号 | 增加 `provisionings` 或等待下发完成 |
| 用户生命周期混乱 | Terraform 管本地用户而 IdP 也在同步 | 生产环境优先 SCIM/IdP，Terraform 只管组和访问配置 |
| 临时凭证风险过高 | 允许用户下载凭证 | 保持 `allow_user_to_get_credentials = false` |
