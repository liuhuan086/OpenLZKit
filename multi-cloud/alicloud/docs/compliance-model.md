# Alibaba Cloud Compliance Model

## 1. 解决的企业问题

策略即代码只能在变更前发现问题，组织管控策略只能阻断部分高危动作。
企业还需要运行时持续检测：资源是否缺标签、OSS 是否公网暴露、磁盘是否加密、
安全组是否开放高危端口，并跨账号聚合结果。

## 2. 使用的云原生服务

- **Cloud Config configuration recorder**：持续记录资源配置。
- **Cloud Config aggregator**：跨账号/文件夹聚合配置与合规结果。
- **Aggregate config rule**：跨账号托管规则。
- **Aggregate compliance pack**：规则包分组与风险归类。
- **Aggregate delivery**：向 SLS/OSS/MNS 等中心目的地投递快照与不合规事件。

## 3. Terraform 模块边界

由 [`modules/compliance`](../modules/compliance) 实现：

- **负责**：recorder、aggregator、aggregate rules、compliance packs、aggregate delivery。
- **不负责**：创建审计日志目的地、组织 deny 策略、plan-time Rego 校验、自动修复。

## 4. 推荐规则集

| 规则 | 目标 |
|---|---|
| required tags | FinOps 与资产责任 |
| OSS public access | 数据泄露风险 |
| disk encryption | 数据保护 |
| security group public high-risk ports | 入侵面控制 |
| ActionTrail enabled | 审计连续性 |

## 5. 输入、输出与依赖

- 输入：`folder_id`、`aggregate_rules`、`compliance_packs`、`deliveries`。
- 输出：`aggregator_id`、`aggregate_rule_ids`、`compliance_pack_ids`、`delivery_channel_ids`。
- 依赖：Cloud Config 可用；目标账号或 folder 已存在；投递目的地已创建。

## 6. 测试

静态检查（无需云账号）：`fmt` + `init -backend=false` + `validate`，见
[../tests/README.md](../tests/README.md)。`plan` 需 sandbox compliance account。

## 7. 回滚

- 先删除 delivery channel。
- 删除 compliance pack。
- 删除 aggregate config rules。
- 删除 aggregator。
- 最后按需关闭 configuration recorder。

## 8. 常见故障排查

| 现象 | 可能原因 | 处理 |
|---|---|---|
| 聚合器无账号 | folder id 不正确或 RD 权限不足 | 使用 org 输出 folder id 并确认 Cloud Config 权限 |
| 规则创建失败 | managed rule identifier 不存在 | 使用阿里云托管规则标识并在 sandbox 验证 |
| 投递失败 | target ARN 或权限错误 | 先创建 SLS/OSS 目的地并授权 Cloud Config |
| 合规包为空 | rule_keys 未匹配模块规则 key | 对齐 `compliance_packs[*].rule_keys` 与 `aggregate_rules` |
