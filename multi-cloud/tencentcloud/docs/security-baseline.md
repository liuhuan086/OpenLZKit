# Tencent Cloud Security Baseline

## 目标

腾讯云安全基线由组织管控策略、CAM 最小权限、CloudAudit + CLS 集中日志、CSIP/安全中心运行时检测和分账标签组成。高风险动作应在组织节点层前移阻断，运行时风险由集中安全账号持续发现。

## 云原生服务

- 组织管控策略：限制关闭审计、删除日志、使用未批准地域等高危动作。
- CAM Policy/Role：最小权限和跨账号临时访问。
- CloudAudit：操作审计。
- CLS：日志集中存储、检索和投递。
- CSIP / 安全中心：运行时风险发现。
- Tag / 分账标签：资源归属和成本治理。

## 模块边界

- [`modules/control-policies`](../modules/control-policies)：组织管控策略和附加。
- [`modules/compliance`](../modules/compliance)：CloudAudit/CSIP 类运行时合规。
- [`modules/logging`](../modules/logging)：CLS 日志集、Topic 和审计投递。
- [`modules/identity`](../modules/identity)：CAM 基线和角色。

不负责：

- 企业 SOC 工单和告警规则全量目录。
- 第三方安全设备接入。
- 业务应用漏洞修复。

## 推荐基线

| 控制 | 默认 |
|---|---|
| 审计 | 禁止关闭 CloudAudit 和删除审计日志。 |
| 地域 | 只允许批准地域创建资源。 |
| 公网暴露 | 禁止高危端口对 0.0.0.0/0 开放。 |
| 权限 | 禁止长期 SecretKey 作为 CI 默认方式。 |
| 标签 | 强制 owner、cost_center、env、project、data_classification。 |
| 日志 | CloudAudit 和关键服务日志进入集中 CLS。 |

## 输入、输出与依赖

主要输入：

- `policies`
- `attachments`
- `audit_tracks`
- `cls_logsets`
- `risk_exports`
- `required_tags`

主要输出：

- `policy_ids`
- `attachment_ids`
- `audit_track_ids`
- `cls_topic_ids`

依赖：

- 腾讯云组织和日志账号已准备。
- 目标节点/成员账号 id 已知。
- 例外流程定义 owner、reason、expiry 和补偿控制。

## 测试

```bash
terraform -chdir=multi-cloud/tencentcloud/live/40-security init -backend=false
terraform -chdir=multi-cloud/tencentcloud/live/40-security validate
terraform -chdir=multi-cloud/tencentcloud/live/45-compliance init -backend=false
terraform -chdir=multi-cloud/tencentcloud/live/45-compliance validate
```

集成测试：把管控策略附加到 sandbox 节点，尝试关闭 CloudAudit 或创建违规安全组，确认被拒绝或产生告警。

## 回滚

- 误阻断时优先移除策略 attachment 或调整条件，不直接删除策略库。
- 日志和审计停用前必须确认替代投递路径。
- 例外到期必须自动复核。

## 常见故障

| 现象 | 排查 |
|---|---|
| 策略不生效 | 检查 attachment target type、节点归属和策略 JSON。 |
| CloudAudit 没有日志 | 检查跟踪集地域、CLS topic、投递权限和存储周期。 |
| 安全组仍公开 | 检查是否资源不在策略覆盖节点，或规则由存量资源手工创建。 |
| CSIP 无发现 | 检查服务开通、资产接入和风险中心过滤条件。 |
