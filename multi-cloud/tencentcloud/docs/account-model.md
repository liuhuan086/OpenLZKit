# Tencent Cloud Account Model

## 目标

腾讯云 Landing Zone 的隔离边界是 TCO 组织节点 + 成员账号。组织节点用于策略继承和部门/环境分层，成员账号用于资源、账单和权限边界。不要在主账号中承载业务资源；主账号只做组织、计费、审计和紧急治理入口。

## 云原生服务

- 腾讯云组织（TCO）：组织节点、成员账号和策略附加。
- 成员账号：业务、平台、安全、日志、网络等资源边界。
- 管控策略：组织或节点层的权限上限。
- 分账标签 / 预算：成本归因和预算告警。
- CAM 角色：跨账号管理入口。

## 推荐层级

```text
root
├── platform
│   ├── security
│   ├── logging
│   └── network
├── workloads
│   ├── prod
│   └── nonprod
├── sandbox
└── suspended
```

设计要点：

- security/logging/network 使用独立成员账号。
- prod/nonprod/sandbox 位于不同节点，继承不同管控策略。
- suspended 节点用于回收前保留账号和审计证据。
- 成员账号创建有计费与实名流程风险，默认空 map，必须显式开启。

## 模块边界

- [`modules/org`](../modules/org)：组织节点层级。
- [`modules/account-factory`](../modules/account-factory)：成员账号售卖。
- [`modules/department`](../modules/department)：部门节点、CAM 角色、预算和策略组合。

不负责：

- 企业实名认证、合同和付款方式。
- 存量账号中业务资源迁移。
- 业务资源本身创建。

## 输入、输出与依赖

主要输入：

- `organization_nodes`
- `member_accounts`
- `departments`
- `tags`
- `budget_rules`

主要输出：

- `node_ids`
- `member_uins`
- `department_node_ids`

依赖：

- 主账号已启用腾讯云组织。
- 执行身份具备组织、CAM、计费相关权限。
- 成员账号命名、邮箱/联系人和成本中心已通过审批。

## 测试

```bash
terraform -chdir=multi-cloud/tencentcloud/live/10-org init -backend=false
terraform -chdir=multi-cloud/tencentcloud/live/10-org validate
terraform -chdir=multi-cloud/tencentcloud/modules/account-factory init -backend=false
terraform -chdir=multi-cloud/tencentcloud/modules/account-factory validate
```

集成测试：在 sandbox 组织节点创建测试成员账号或使用假数据 plan，确认节点归属、标签和预算输入完整。

## 回滚

- 先移除账号中的业务权限、共享资源和网络接入。
- 将成员账号移动到 suspended 节点。
- 账号注销或移出组织必须经过计费、审计和数据保留审批。

## 常见故障

| 现象 | 排查 |
|---|---|
| 成员账号创建失败 | 检查组织状态、实名/计费要求、联系人信息和配额。 |
| 节点策略未继承 | 检查账号是否位于目标节点，是否存在更低层策略覆盖。 |
| 成本无法归因 | 检查分账标签、预算维度和成员账号归属。 |
| 主账号权限滥用 | 限制主账号日常登录，改用 CAM 角色和审批流程。 |
