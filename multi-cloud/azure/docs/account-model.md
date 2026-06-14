# Azure Account Model

## 目标

Azure Landing Zone 的隔离边界是 Management Group + Subscription。管理组承载策略继承和权限边界，订阅承载账单、配额、资源生命周期和环境隔离。不要把多个环境、多个业务或平台共享服务放进同一个订阅里；订阅售卖流程应当像产品一样可申请、可审批、可审计、可回收。

## 云原生服务

- Management Groups：表达平台、应用、环境和策略继承层级。
- Subscriptions：工作负载和平台服务的资源与账单边界。
- Azure Policy：在管理组或订阅层做 guardrails。
- RBAC：在管理组、订阅、资源组或资源层授权。
- Tags：成本中心、owner、环境和数据分级。

## 推荐层级

```text
Tenant Root Group
├── Platform
│   ├── Identity
│   ├── Management
│   └── Connectivity
├── LandingZones
│   ├── Corp
│   └── Online
├── Sandbox
└── Decommissioned
```

设计要点：

- 平台订阅承载共享身份、监控、日志、网络等能力。
- 应用 landing zone 订阅由 subscription vending 创建，默认继承上层 Azure Policy。
- Sandbox 独立管理组，策略可宽松但成本和公网暴露必须受控。
- `Decommissioned` 管理组用于保留待销毁订阅，避免误删审计证据。

## 模块边界

- [`modules/org`](../modules/org)：创建管理组层级和基础 RBAC。
- [`modules/subscription-vending`](../modules/subscription-vending)：把已有或新售卖订阅关联到管理组，并附加标签。
- [`modules/department`](../modules/department)：按业务部门组合管理组、预算、RBAC 和策略。

不负责：

- 购买 Enterprise Agreement / MCA 计费账户。
- 手工迁移存量订阅中的资源。
- 业务团队在订阅内创建具体应用资源。

## 输入、输出与依赖

主要输入：

- `root_management_group_id`
- `management_groups`
- `subscriptions`
- `subscription_id`
- `department_management_groups`
- `tags`

主要输出：

- `management_group_ids`
- `subscription_association_ids`
- `department_management_group_ids`

依赖：

- 执行身份具备 tenant root 或目标管理组的管理权限。
- 订阅已存在且未被其他流程锁定。
- 新订阅售卖需要企业计费账户和审批流程，本仓默认不自动购买真实订阅。

## 测试

```bash
terraform -chdir=multi-cloud/azure/live/10-org init -backend=false
terraform -chdir=multi-cloud/azure/live/10-org validate
terraform -chdir=multi-cloud/azure/modules/subscription-vending init -backend=false
terraform -chdir=multi-cloud/azure/modules/subscription-vending validate
```

集成测试在 sandbox tenant 中执行：创建一个测试管理组，关联一条非生产订阅，确认 Azure Policy 和 RBAC 从父管理组继承。

## 回滚

- 先移除订阅上的工作负载 role assignment 和 policy assignment 例外。
- 将订阅移动到 `Decommissioned` 或原父管理组。
- 删除空管理组；已承载策略、锁或子管理组的节点不能直接删除。

## 常见故障

| 现象 | 排查 |
|---|---|
| 管理组创建失败 | 检查 tenant root 权限和管理组 id 是否全局唯一。 |
| 订阅关联失败 | 确认订阅在同一 Entra tenant，且执行身份有订阅 Owner 或管理组权限。 |
| 策略未继承 | 检查订阅是否挂在正确管理组，是否存在下层 exemption。 |
| 账单无法归因 | 检查订阅和资源组标签是否包含 `cost_center`、`owner`、`env`。 |
