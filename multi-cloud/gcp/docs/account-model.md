# Google Cloud Account Model

## 目标

Google Cloud 的资源隔离边界是 Organization + Folder + Project。Folder 承载组织、环境、部门和策略继承，Project 承载资源、IAM、API、配额和账单。Landing Zone 不应把所有资源放在一个 project；每个工作负载环境至少应有独立 project，并通过 project factory 标准化创建。

## 云原生服务

- Organization：企业根资源，绑定 Cloud Identity / Google Workspace。
- Folders：按平台、环境、部门和合规边界组织 project。
- Projects：资源、API、配额、计费和 IAM 边界。
- Billing Account：计费关联与预算归因。
- Resource Manager Tags / Labels：治理、成本和自动化元数据。

## 推荐层级

```text
organizations/<org-id>
├── folders/platform
│   ├── folders/security
│   ├── folders/logging
│   └── folders/network
├── folders/workloads
│   ├── folders/prod
│   └── folders/nonprod
├── folders/sandbox
└── folders/decommissioned
```

设计要点：

- `platform` folder 下承载共享安全、日志、网络和自动化 project。
- `workloads/prod` 和 `workloads/nonprod` 分开继承组织策略。
- sandbox 不接入生产 Shared VPC，也不拥有生产数据访问。
- project 删除有延迟和恢复窗口；生产回收先移入 `decommissioned`。

## 模块边界

- [`modules/org`](../modules/org)：Folder 层级。
- [`modules/project-factory`](../modules/project-factory)：Project 创建、billing 关联、labels。
- [`modules/department`](../modules/department)：部门 Folder、IAM、预算和策略组合。

不负责：

- 创建 Google Workspace / Cloud Identity 租户。
- 自动购买或变更 billing account。
- 把存量 project 无损迁移到新 folder。

## 输入、输出与依赖

主要输入：

- `organization_id`
- `folders`
- `projects`
- `billing_account`
- `labels`

主要输出：

- `folder_ids`
- `project_ids`
- `project_numbers`

依赖：

- 执行身份具备 `resourcemanager.folders.*`、`resourcemanager.projects.*` 和 billing 关联权限。
- 组织策略允许目标区域、API 和项目创建。
- Project id 全局唯一且不可复用，命名需要稳定。

## 测试

```bash
terraform -chdir=multi-cloud/gcp/live/10-org init -backend=false
terraform -chdir=multi-cloud/gcp/live/10-org validate
terraform -chdir=multi-cloud/gcp/modules/project-factory init -backend=false
terraform -chdir=multi-cloud/gcp/modules/project-factory validate
```

集成测试：在 sandbox org/folder 创建一个测试 project，确认 labels、billing、folder parent 和启用 API 符合预期。

## 回滚

- 先移除业务 IAM、网络接入和日志 sink。
- 将 project 移入 decommissioned folder，保留审计窗口。
- 只有确认无生产依赖后才 schedule delete。

## 常见故障

| 现象 | 排查 |
|---|---|
| Project 创建失败 | 检查 project id 是否全局唯一、billing 权限是否可用。 |
| API 启用失败 | 检查 serviceusage 权限和 org policy 是否禁用服务。 |
| Folder 策略未继承 | 确认 project parent 是否正确，是否存在下层 override。 |
| 成本无法归因 | 检查 labels、billing account 和预算过滤条件。 |
