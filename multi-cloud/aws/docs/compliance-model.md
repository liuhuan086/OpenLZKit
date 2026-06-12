# AWS Compliance Model

## 目标

FP-7 建立运行时合规与持续检测能力，用 AWS Config、Security Hub 和 GuardDuty 发现未打标签、公开存储、未加密资源、异常威胁信号和审计能力关闭等问题。它补充 FP-2 的组织护栏：SCP 负责阻断高风险动作，Config/Security Hub/GuardDuty 负责发现和聚合运行时风险。

## 云原生服务

- AWS Config organization aggregator：跨账号、跨区域聚合配置合规结果。
- AWS Config managed rule：检测标签、加密、公开访问、审计配置等常见问题。
- AWS Config conformance pack：把一组规则作为治理包统一部署。
- Security Hub：聚合安全标准和 findings。
- GuardDuty：检测威胁、异常行为和恶意活动。

## 模块边界

由 [`modules/compliance`](../modules/compliance) 实现：

- **负责**：启用当前账号 Security Hub、订阅 Security Hub standards、注册 Security Hub/GuardDuty organization admin、启用 GuardDuty detector、创建 Config organization aggregator、Config managed rule、Config conformance pack。
- **不负责**：创建 Config recorder 的 S3/KMS/log archive 依赖、创建 SCP、创建所有 delegated admin 服务、自动修复 findings。

下游协作：

- `modules/org-policies` 阻断关闭审计和检测服务。
- `modules/logging` 提供集中 S3/KMS/CloudTrail 审计归档；Config delivery channel 后续继续深化。
- `modules/delegation` 统一管理 Organizations delegated administrator。

## 推荐检测基线

| 类别 | 推荐能力 |
|---|---|
| 标签 | Config `REQUIRED_TAGS` |
| 存储公开 | Config `S3_BUCKET_PUBLIC_READ_PROHIBITED`、`S3_BUCKET_PUBLIC_WRITE_PROHIBITED` |
| 加密 | Config `ENCRYPTED_VOLUMES`、RDS/EBS/S3 加密规则 |
| 审计 | Config recorder、CloudTrail、GuardDuty、Security Hub 启用检测 |
| 威胁 | GuardDuty detector + Security Hub findings 聚合 |

## 输入、输出与依赖

主要输入：

- `enable_security_hub`
- `security_hub_admin_account_id`
- `security_hub_standards`
- `enable_guardduty_detector`
- `guardduty_admin_account_id`
- `config_aggregators`
- `config_managed_rules`
- `conformance_packs`

主要输出：

- `config_aggregator_names`
- `config_rule_names`
- `conformance_pack_names`
- `guardduty_detector_ids`

依赖：

- 组织管理账号或具备对应服务组织权限的安全账号。
- Config aggregator role 已存在。
- Conformance pack delivery bucket 已按生产要求创建时，再配置 delivery bucket。
- Organizations 服务访问和 delegated admin 流程已审批。

## 测试

静态检查：

```bash
terraform -chdir=multi-cloud/aws/examples/compliance fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/compliance init -backend=false
terraform -chdir=multi-cloud/aws/examples/compliance validate

terraform -chdir=multi-cloud/aws/live/45-compliance fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/45-compliance init -backend=false
terraform -chdir=multi-cloud/aws/live/45-compliance validate
```

集成验证：

- 在 sandbox security account 启用 Security Hub 和 GuardDuty。
- 创建只覆盖 sandbox OU 的 Config aggregator。
- 部署一组最小 Config managed rule，确认 findings 进入 Security Hub。
- 确认关闭 CloudTrail/Config/GuardDuty 的动作仍由 FP-2 SCP 阻断。

## 回滚

- 先移除 Config conformance pack 和 managed rule。
- 删除 Config aggregator。
- 取消 Security Hub standards subscription。
- 禁用 GuardDuty detector 或移除组织 admin 配置。
- 禁用 Security Hub 前先确认 findings 已归档。

## 常见故障

| 现象 | 排查 |
|---|---|
| Config aggregator 创建失败 | 检查 `role_arn` trust 和 Organizations 权限。 |
| Conformance pack 部署失败 | 检查 template body、delivery bucket 和 Config recorder 状态。 |
| Security Hub admin 注册失败 | 确认在管理账号操作，且目标账号是组织成员账号。 |
| GuardDuty 未聚合成员账号 | 检查 organization admin、成员自动启用和区域覆盖。 |
