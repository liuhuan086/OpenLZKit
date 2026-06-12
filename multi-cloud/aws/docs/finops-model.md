# AWS FinOps Model

## 目标

FinOps 域把账号、部门、环境和项目的成本治理落到 AWS 原生能力中：预算告警、异常检测、成本分类、CUR 明细导出、QuickSight BI 接入和标签基线协同工作。Tag Policy 已由组织护栏和部门模块承载；FP-10 聚焦 AWS Budgets、Cost Anomaly Detection、Cost Categories、Cost and Usage Reports 和 BI handoff。

## 云原生服务

- AWS Budgets：按账号、标签、服务或部门维度设置预算和告警。
- Cost Anomaly Detection：发现异常成本增长并通知 FinOps 团队。
- Cost Categories：把账号、部门、环境、项目映射为统一成本归集口径。
- Cost and Usage Reports：把账单明细导出到 S3，支撑 Athena、QuickSight 或第三方 FinOps 平台。
- QuickSight：提供 Athena data source、folder、group 等 BI 接入资产。
- Organizations Tag Policy：标准化成本标签键和值域。

## 模块边界

由 [`modules/finops`](../modules/finops) 实现：

- **负责**：创建 Budgets、预算通知、Cost Anomaly Detection monitor/subscription、Cost Categories、CUR report definition、可选加固 S3 bucket、QuickSight Athena data source、folder 和 group。
- **不负责**：创建 Organizations Tag Policy、创建账号、创建完整 dashboard/analysis。

下游协作：

- `modules/org-policies` 和 `modules/department` 约束标签。
- `modules/account-factory` 在账号创建时强制治理标签。
- CUR 可通过 Athena artifact 输出到加固 S3 bucket，并通过 QuickSight Athena data source 接入 BI 工作区。

## 推荐治理基线

| 场景 | 控制 |
|---|---|
| sandbox 限额 | 月度 budget + forecasted 80%/100% 告警 |
| 部门成本归集 | Cost Category 按 linked account、tag 或 account name 分类 |
| 异常费用 | Service monitor + daily subscription |
| 生产预算 | 部门/项目级 budget + SNS/Email 告警 |

## 输入、输出与依赖

主要输入：

- `budgets`
- `anomaly_monitors`
- `anomaly_subscriptions`
- `cost_categories`
- `cur_buckets`
- `cur_reports`
- `quicksight_athena_data_sources`
- `quicksight_folders`
- `quicksight_groups`

主要输出：

- `budget_ids`
- `anomaly_monitor_arns`
- `anomaly_subscription_arns`
- `cost_category_arns`
- `cur_bucket_names`
- `cur_report_names`
- `quicksight_data_source_arns`
- `quicksight_folder_arns`
- `quicksight_group_arns`

依赖：

- Billing/Cost Explorer 已启用。
- 通知邮箱或 SNS topic 已通过企业流程审核。
- Cost Category 规则与账号命名、标签策略保持一致。

## 测试

静态检查：

```bash
terraform -chdir=multi-cloud/aws/examples/finops fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/finops init -backend=false
terraform -chdir=multi-cloud/aws/examples/finops validate

terraform -chdir=multi-cloud/aws/live/60-finops fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/60-finops init -backend=false
terraform -chdir=multi-cloud/aws/live/60-finops validate
```

集成验证：

- 先在 sandbox payer/management account 创建低额度预算。
- 确认预算通知发送到 FinOps 邮箱或 SNS topic。
- 创建 service-level anomaly monitor，确认 subscription 配置有效。
- 创建一个只覆盖测试账号的 Cost Category，验证成本分类结果。
- 创建一个 sandbox CUR report，确认 S3 bucket policy、Athena artifact 和明细落盘路径符合预期。
- 创建 QuickSight Athena data source 和 FinOps folder/group，确认 BI 团队可继续创建 dataset/dashboard。

## 回滚

- 先删除预算通知或订阅，避免误报。
- 删除 budgets、anomaly subscriptions、monitors。
- 删除 Cost Categories 前确认报表和下游流程不再依赖。
- 删除 CUR report 前确认 Athena/BI/成本分析任务已迁移或停止。
- 删除 QuickSight folder/data source 前确认 dashboard/analysis 已迁移或停用。

## 常见故障

| 现象 | 排查 |
|---|---|
| Budget 创建失败 | 检查 payer/management account 权限和 Cost Explorer 是否启用。 |
| 通知未收到 | 检查邮箱、SNS topic policy 和订阅确认状态。 |
| Anomaly monitor 无数据 | 成本数据通常有延迟，确认 monitor dimension/specification 正确。 |
| Cost Category 不匹配 | 检查 linked account name、tag key/value 和规则优先级。 |
| CUR 未落盘 | 检查 bucket policy、payer/management account 权限、report prefix 和账单数据延迟。 |
| QuickSight 接入失败 | 检查 QuickSight 账号订阅、namespace、Athena workgroup、data source 权限和 principal ARN。 |
