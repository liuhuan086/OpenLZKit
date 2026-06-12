# AWS Department Model

## 目标

业务部门管理用于表达企业内部的责任边界：哪个部门拥有账号，谁承担成本，哪些组织护栏适用，哪些平台或 SSO 主体可以进入部门管理角色。它补在账号工厂之后、跨账号访问和 IAM Identity Center 之前，避免把所有业务线都压到同一个 Workloads OU 下。

## 云原生服务

- AWS Organizations OU：每个业务部门一个 OU，作为账号、策略和成本归属边界。
- AWS Organizations Policy Attachment：把全局 SCP 或 Tag Policy 附加到部门 OU。
- AWS Organizations Tag Policy：为部门固定 `owner`、`cost_center`、`env`、`data_classification` 等值域。
- IAM Role + STS AssumeRole：部门管理员角色，信任平台、SSO 或自动化主体。

## 模块边界

由 [`modules/department`](../modules/department) 实现：

- **负责**：创建部门 OU、部门管理员 IAM role、角色托管策略附件、部门 Organizations policy attachment、部门 Tag Policy。
- **不负责**：创建成员账号、创建全局 SCP/Tag Policy、分配 IAM Identity Center 用户/组、创建跨账号 workload role。

下游协作：

- `modules/account-factory` 使用 `ou_ids` 把成员账号售卖到部门 OU。
- `modules/org-policies` 先创建全局 SCP/Tag Policy，部门模块只引用 policy id。
- 后续 `modules/identity-center` 把 SSO group 分配到部门账号或部门管理角色。
- 后续 `modules/cross-account-access` 创建安全、CI/CD、日志等跨账号角色。

## 输入、输出与依赖

主要输入：

- `parent_ou_id`：部门 OU 的父 OU，通常是 `module.org.ou_ids["workloads"]`。
- `departments`：部门 map，包含显示名称、owner、cost center、可信主体、角色策略、组织策略、标签值域。
- `create_tag_policies`：是否为每个部门创建并附加专属 Tag Policy。

主要输出：

- `ou_ids`
- `role_names`
- `role_arns`
- `tag_policy_ids`
- `standard_tags`

依赖：

- AWS Organizations 已启用。
- 父 OU 已存在。
- 调用身份具备 Organizations 与 IAM role 管理权限。
- `trusted_principal_arns` 必须是精确 ARN，不允许 `*`。

## 推荐部门结构

```text
Workloads
├── Payments
├── Data Platform
└── Customer Experience
```

部门 OU 下再通过账号工厂创建 `prod`、`nonprod`、`sandbox` 等账号。部门维度用于归属和护栏，环境维度继续由账号或子 OU 表达。

## 测试

静态检查：

```bash
terraform -chdir=multi-cloud/aws/examples/departments fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/departments init -backend=false
terraform -chdir=multi-cloud/aws/examples/departments validate

terraform -chdir=multi-cloud/aws/live/15-departments fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/15-departments init -backend=false
terraform -chdir=multi-cloud/aws/live/15-departments validate
```

集成验证：

- 使用 sandbox management account 或受控委派身份执行 plan。
- 先创建一个测试部门 OU，不附加生产级 SCP。
- 确认部门 role trust policy 只包含预期平台/SSO/自动化主体。
- 确认部门 Tag Policy 不会阻断现有关键资源标签。

## 回滚

- 先移除部门级 Organizations policy attachment 和 Tag Policy attachment。
- 迁移或回收部门 OU 下的成员账号。
- 删除部门管理员角色及其策略附件。
- 删除空部门 OU。

## 常见故障

| 现象 | 排查 |
|---|---|
| 部门 OU 创建失败 | 确认 `parent_ou_id` 是有效 OU id，且执行身份具备 Organizations 权限。 |
| 部门角色无法 AssumeRole | 检查 `trusted_principal_arns` 是否是实际调用主体 ARN；不要使用 wildcard。 |
| 组织策略附加失败 | 确认 `organization_policy_ids` 已由 `modules/org-policies` 创建，且策略类型适用于目标。 |
| Tag Policy 没有强制拦截 | Tag Policy 主要标准化标签值域；强制拒绝需要结合 SCP、Config 或 CI policy-as-code。 |
