# Alibaba Cloud Account Model

## 1. 解决的企业问题

资源、账号、权限随业务增长失控。通过 Resource Directory 把账号按职责和环境分层，
降低爆炸半径，使权限、计费和审计有清晰边界。

## 2. 使用的云原生服务

- **Resource Directory（资源目录）**：企业多账号组织根，提供 folders 和成员账号。
- **Folder（资源夹）**：按职责/环境分组的层级容器。
- **成员账号（member account）**：承载实际资源的隔离边界。

## 3. Terraform 模块边界

由 [`modules/org`](../modules/org) 实现：

- **负责**：读取已启用的 Resource Directory，创建 folder 层级。
- **不负责**：启用 Resource Directory（属 `live/00-bootstrap` 的一次性操作）、RAM、网络、日志、计费。

由 [`modules/account-factory`](../modules/account-factory) 实现：

- **负责**：按标准契约创建成员账号，放入指定 folder，合并并校验 FinOps 标签。
- **不负责**：创建 folder、配置账号内 RAM/网络/日志基线、处理账号回收流程。

## 4. 输入、输出与依赖

- `modules/org` 输入：`name_prefix`、`folders`（一到两级层级）。
- `modules/org` 输出：`root_folder_id`、`folder_ids`。
- `modules/account-factory` 输入：`folder_ids`、可选 `accounts`、`common_tags`、`required_tag_keys`。
- `modules/account-factory` 输出：`account_ids`、`account_display_names`。
- 依赖：Resource Directory 已启用；调用方具备 ResourceManager 权限。

## 5. 推荐账号/文件夹结构

```text
management account (root)
├── Security
│   ├── Audit Log
│   └── Security Tooling
├── Infrastructure
│   ├── Network
│   └── Shared Services
├── Workloads
│   ├── Prod
│   └── Dev
└── Sandbox
```

原则：管理账号不承载业务；审计日志账号独立；网络账号独立；生产与非生产分离；
sandbox 必须有预算与限额。

## 6. 测试

静态检查（无需云账号）：`fmt` + `init -backend=false` + `validate`，见
[../tests/README.md](../tests/README.md)。`plan` 需 sandbox 管理账号凭证。

## 7. 回滚

- 删除新增 folder/account 的对应配置后 `plan`/`apply`。
- 成员账号删除受阿里云回收策略约束，需按官方流程处理，不能直接强删。

## 8. 常见故障排查

| 现象 | 可能原因 | 处理 |
|---|---|---|
| `directories` 为空 | Resource Directory 未启用 | 先在 `00-bootstrap` 启用 |
| 创建 folder 报权限错误 | 调用方缺 ResourceManager 权限 | 使用管理账号 RAM 角色 |
| 账号无法删除 | 阿里云成员账号回收限制 | 走官方账号回收流程 |
