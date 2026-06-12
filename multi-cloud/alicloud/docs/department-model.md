# Alibaba Cloud Department Model

## 1. 解决的企业问题

当企业业务线增多时，单纯按环境划分账号不够。平台团队还需要表达业务部门
的责任边界：谁拥有账号、谁承担成本、哪些组织护栏适用、哪些人员可进入部门
管理角色。

## 2. 使用的云原生服务

- **Resource Directory Folder**：部门级组织边界。
- **RAM Role + STS AssumeRole**：部门管理角色，限定可信主体。
- **Resource Directory Control Policy**：部门级组织护栏。
- **Tag Policy**：部门级成本归属与数据分类约束。

## 3. Terraform 模块边界

由 [`modules/department`](../modules/department) 实现：

- **负责**：创建部门 folder、部门管理 RAM 角色、部门 tag policy、部门 control policy attachment。
- **不负责**：创建成员账号、创建全局管控策略、CloudSSO 访问分配、工作负载资源接入。

下游模块协作：

- `modules/account-factory` 使用 `folder_ids` 把成员账号售卖到部门 folder。
- `modules/control-policies` 先创建全局策略，部门模块只引用 policy id。
- `modules/sso` 后续把 CloudSSO 用户/组分配到部门账号或角色。

## 4. 输入、输出与依赖

- 输入：`parent_folder_id`、`departments`、`name_prefix`、`create_tag_policies`。
- 输出：`folder_ids`、`role_names`、`role_arns`、`tag_policy_ids`、`standard_tags`。
- 依赖：Resource Directory 已启用；父 folder 已存在；调用方具备 ResourceManager、RAM、Tag Policy 权限。

## 5. 推荐部门结构

```text
Workloads
├── Payments
├── Data Platform
└── Customer Experience
```

部门 folder 下再通过账号工厂创建 `prod`、`dev`、`sandbox` 等成员账号。

## 6. 测试

静态检查（无需云账号）：`fmt` + `init -backend=false` + `validate`，见
[../tests/README.md](../tests/README.md)。`plan` 需 sandbox 管理账号凭证。

## 7. 回滚

- 先解绑部门 control policy 与 tag policy。
- 再迁移或回收部门下成员账号。
- 最后删除部门 folder 与 RAM 角色。

## 8. 常见故障排查

| 现象 | 可能原因 | 处理 |
|---|---|---|
| 部门 folder 创建失败 | `parent_folder_id` 不存在或权限不足 | 使用 `10-org` 输出的 folder id，并确认 ResourceManager 权限 |
| 部门角色无法 AssumeRole | `trusted_principals` 不匹配实际主体 | 使用精确 RAM/SSO/平台角色 ARN |
| 策略附加失败 | `control_policy_ids` 不存在或 Control Policy 未启用 | 先部署 `40-security` 管控策略 |
| 资源打标失败 | 部门 tag policy 值约束不匹配 | 对齐 `owner`、`cost_center`、`env`、`data_classification` |
