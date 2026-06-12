# AWS Logging And Operations Runbook

## 目标

日志归档是企业 Landing Zone 的审计底座：组织级 CloudTrail、Config/SecurityHub/GuardDuty findings、VPC Flow Logs 和服务访问日志最终都应进入专用 log archive 账号，并使用加密、版本化、对象锁和保留期保护。FP-9 第一版聚焦 CloudTrail 组织级审计归档，并提供 Firehose 到 S3 的通用日志接入通道。

## 云原生服务

- S3 log archive bucket：集中存储审计日志。
- S3 Object Lock + Versioning：防误删和防篡改。
- S3 Public Access Block + bucket policy：阻断公开访问并允许 CloudTrail 写入。
- KMS：日志加密。
- CloudWatch Logs：CloudTrail 近实时投递。
- CloudTrail organization trail：组织级多区域管理事件与可选数据事件审计。
- Kinesis Data Firehose：把应用、网络或服务日志缓冲、压缩后写入 log archive S3。

## 模块边界

由 [`modules/logging`](../modules/logging) 实现：

- **负责**：创建/消费 log archive bucket、KMS key、CloudWatch log group、组织级 CloudTrail、S3 bucket policy、Object Lock、版本化、加密配置和可选 Firehose S3 delivery stream。
- **不负责**：Security Lake、每类业务服务日志源配置、SIEM 集成。

下游协作：

- `modules/compliance` 产生 Config/SecurityHub/GuardDuty findings。
- `modules/org-policies` 阻断删除日志和关闭审计能力。
- VPC Flow Logs、S3 access logs、应用日志可通过 Firehose 进入同一归档模型；Security Lake 可作为后续安全数据湖扩展。

## 输入、输出与依赖

主要输入：

- `log_bucket_name`
- `create_log_bucket`
- `object_lock_enabled`
- `object_lock_retention_days`
- `create_kms_key`
- `kms_key_arn`
- `cloudtrail`
- `event_selectors`
- `firehose_streams`

主要输出：

- `log_bucket_name`
- `kms_key_arn`
- `cloudtrail_arn`
- `firehose_stream_arns`
- `cloudwatch_log_group_name`

依赖：

- 在 management account 或 log archive/security account 的受控身份中运行。
- 生产启用 Object Lock 前确认 bucket 创建策略；Object Lock 只能在 bucket 创建时开启。
- 如启用 CloudWatch Logs delivery，需要提供 CloudTrail 可 assume 的 role ARN。

## 测试

静态检查：

```bash
terraform -chdir=multi-cloud/aws/examples/logging fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/logging init -backend=false
terraform -chdir=multi-cloud/aws/examples/logging validate

terraform -chdir=multi-cloud/aws/live/50-logging fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/50-logging init -backend=false
terraform -chdir=multi-cloud/aws/live/50-logging validate
```

集成验证：

- 在 sandbox log archive account 创建日志桶和 KMS key。
- 启用组织级 CloudTrail，确认管理事件进入 S3。
- 创建 Firehose delivery stream，确认业务日志按 prefix、压缩和错误路径进入 S3。
- 测试 Object Lock 默认保留期和版本化。
- 确认非授权主体不能删除日志对象或修改 bucket policy。

## 回滚

- 先停止 CloudTrail logging 或切换到替代日志桶。
- 移除 CloudTrail event selectors 和 CloudWatch delivery。
- 停止或迁移 Firehose 生产者，再删除 delivery stream。
- 删除 CloudTrail。
- 只有在保留期、合规和审计要求允许时，才销毁日志桶和 KMS key。

## 常见故障

| 现象 | 排查 |
|---|---|
| CloudTrail 无法写入 S3 | 检查 bucket policy、S3 key prefix、组织 trail ARN 和 ACL condition。 |
| CloudWatch Logs 不投递 | 检查 `cloud_watch_logs_role_arn` trust policy 和 log group ARN。 |
| Firehose 写入失败 | 检查 Firehose role 的 S3/KMS 权限、bucket ARN、prefix 和错误输出路径。 |
| Object Lock 配置失败 | 确认 bucket 创建时已启用 Object Lock。 |
| KMS 权限不足 | 检查 CloudTrail 和日志读取角色是否具备 KMS encrypt/decrypt 权限。 |
