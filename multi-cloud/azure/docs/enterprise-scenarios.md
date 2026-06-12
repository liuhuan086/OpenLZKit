# Azure 企业级深化路线图

> 把 Azure Landing Zone 做成**企业级标准模范**，与阿里云 / AWS 保持同一套治理标准，但严格使用 Azure 原生模型（Management Group / Subscription / Azure Policy / Entra ID + RBAC / Lighthouse），不照搬其他云。
> 本文是 Azure 实现阶段的权威来源（文档先行）：按功能点（Feature Point, FP）设计 → 实现 → 测试 → 提交，逐轮推进。
> 每个 FP 都遵循仓库统一标准：module + live + README + 测试，通过 CI 五道门禁（`fmt` / `validate` / `tflint` / `checkov` / `conftest`）。

## 设计原则（企业级）

- **Management Group + Subscription 即隔离边界**：用管理组层级表达组织/环境/业务部门，用订阅承载资源与计费边界，而不是把资源堆在一个订阅里。
- **护栏前移**：用 **Azure Policy**（定义 + 计划 + 在管理组层级 assign）在组织层禁止高危配置，等价于 AWS SCP / 阿里云管控策略。
- **人走 Entra ID + PIM，机器走 OIDC/Workload Identity Federation**：人员通过 Entra 组 + RBAC（必要时 PIM 提权）获取最小、可审计、按需的访问；自动化通过 GitHub OIDC 联合凭据换取令牌，杜绝长期密钥。
- **集中而隔离**：日志（Log Analytics）、安全（Defender for Cloud）、网络、合规集中到平台订阅，但 RBAC 最小授权、彼此隔离。
- **可委派**：跨租户/跨订阅管理用 **Azure Lighthouse** 做受限委派；管理组层级用自定义 RBAC 角色委派职责。

## 基础域（与其他云对齐，作为 FP 的底座）

| 域 | Azure 实现 | 关键资源 |
|---|---|---|
| org | 管理组层级 | `azurerm_management_group` |
| identity | 自定义 RBAC 角色 + 分配 | `azurerm_role_definition`、`azurerm_role_assignment` |
| network | Hub-Spoke VNet + 默认拒绝 NSG | `azurerm_virtual_network`、`azurerm_subnet`、`azurerm_network_security_group` |
| security | Azure Policy 安全基线 | `azurerm_management_group_policy_assignment` |
| logging | Log Analytics + 诊断设置 | `azurerm_log_analytics_workspace`、`azurerm_monitor_diagnostic_setting` |
| finops | 预算 + 标签策略 | `azurerm_consumption_budget_management_group` |
| workload-onboarding | 资源组 + 托管身份 + RBAC + 标签 | `azurerm_resource_group`、`azurerm_user_assigned_identity` |

`live/00-bootstrap` 提供远程 state（Azure Storage 后端）与 GitHub OIDC 联合身份（`azuread_application` + `azuread_application_federated_identity_credential`）。

## 深化功能点（计划）

### FP-1 多账号管理：订阅工厂（Subscription Vending）

- **场景**：平台团队按标准流程申领/编排订阅，挂到对应管理组，强制标签与命名。
- **Azure 能力**：Management Group + Subscription（MCA/EA 计费范围下创建别名订阅）。
- **Terraform**：`azurerm_management_group`、`azurerm_subscription`、`azurerm_management_group_subscription_association`。
- **落地**：`modules/subscription-vending`；在 `live/10-org` 消费（默认空 map，创建订阅有计费影响，需显式开启）。
- **验收**：从管理组 key 映射挂载订阅；标签含 FinOps 标签集；fmt+validate 通过。

### FP-2 组织护栏：Azure Policy（SCP 等价）

- **场景**：组织层禁止高危——允许地域白名单、禁止公网入站高危端口、强制加密、强制标签、禁止禁用诊断日志。
- **Azure 能力**：Policy 定义 / 计划集 + 管理组层级 assignment。
- **Terraform**：`azurerm_policy_definition`、`azurerm_policy_set_definition`、`azurerm_management_group_policy_assignment`。
- **落地**：`modules/policy-guardrails`；在 `live/40-security` 附加到 Root / 指定管理组。
- **验收**：policy_rule 为合法 JSON；按 effect（Deny/Audit）声明；可附加到管理组；Conftest 校验策略 JSON 结构。

### FP-3 业务部门管理（Departments）

- **场景**：每个业务部门一个管理组 + 部门级 Policy assignment + 部门 RBAC 角色 + 部门预算与成本标签。
- **Azure 能力**：管理组 + Policy assignment + role assignment + budget 组合。
- **Terraform**：`azurerm_management_group`、`azurerm_management_group_policy_assignment`、`azurerm_role_assignment`、`azurerm_consumption_budget_management_group`。
- **落地**：`modules/department`；在 `live/15-departments` 消费。
- **验收**：每个部门一套隔离边界；部门角色 scope 限定到部门管理组；fmt+validate 通过。

### FP-4 跨订阅访问（Cross-subscription Access）

- **场景**：安全订阅只读审计所有订阅；CI/CD 从自动化身份在工作负载订阅 apply；日志集中收集。
- **Azure 能力**：跨 scope 的 RBAC role assignment；用户分配托管身份；OIDC 联合。
- **Terraform**：`azurerm_role_definition`、`azurerm_role_assignment`（跨订阅 scope）、`azurerm_user_assigned_identity`、`azurerm_federated_identity_credential`。
- **落地**：`modules/cross-account-access`；在 `live/24-cross-account-access` 消费。
- **验收**：role assignment scope 最小且显式；机器身份用联合凭据；正反 Conftest 用例（禁止 Owner@根范围之类过宽授权）。

### FP-5 人员访问：Entra ID 组 + PIM（SSO 等价）

- **场景**：人员通过 Entra 组获得 RBAC，不在订阅内建本地用户；高权限走 PIM 按需提权。
- **Azure 能力**：Entra ID 组、组到 RBAC 角色的 scope 化分配。
- **Terraform**：`azuread_group`、`azurerm_role_assignment`（principal 为组对象）。
- **落地**：`modules/entra-access`；在 `live/25-sso` 消费。
- **验收**：组映射到统一角色模型；分配到管理组/订阅 scope；fmt+validate 通过。

### FP-6 网络互联（Hub-Spoke / Virtual WAN）

- **场景**：Hub-Spoke 跨订阅互联；prod↔shared 私网；sandbox↔prod 默认拒绝；集中出口与 DNS。
- **Azure 能力**：Hub VNet + VNet peering，或 Virtual WAN/虚拟中心。
- **Terraform**：`azurerm_virtual_network`、`azurerm_virtual_network_peering`、`azurerm_virtual_hub`（vWAN 模式）。
- **落地**：`modules/connectivity`；在 `live/35-connectivity` 编排 hub/spoke peering。
- **验收**：CIDR 不重叠；sandbox→prod 无 peering；fmt+validate 通过。

### FP-7 集中合规（Defender for Cloud + Policy 合规）

- **场景**：运行时持续检测——未加密、公网暴露、缺标签、未启用诊断——跨订阅汇总。
- **Azure 能力**：Microsoft Defender for Cloud 计划 + Azure Policy 合规 + Log Analytics。
- **Terraform**：`azurerm_security_center_subscription_pricing`、`azurerm_security_center_contact`、`azurerm_management_group_policy_assignment`（审计类）。
- **落地**：`modules/compliance`；在 `live/45-compliance` 消费。
- **验收**：Defender 计划覆盖关键资源类型；与 plan-time Conftest 互补；fmt+validate 通过。

### FP-8 委派管理与跨租户（Azure Lighthouse）

- **场景**：把安全/网络/合规管理委派给专用平台租户/订阅；受限、可审计的跨租户管理。
- **Azure 能力**：Azure Lighthouse 委派定义与分配。
- **Terraform**：`azurerm_lighthouse_definition`、`azurerm_lighthouse_assignment`。
- **落地**：`modules/delegation`；在 `live/55-delegation` 消费。
- **验收**：授权角色最小且不可含 Owner；委派范围受限；fmt+validate 通过。

## 推进顺序

00-bootstrap → 10-org（含基础 org + FP-1 订阅工厂）→ 15-departments（FP-3）→ 20-identity（基础 RBAC）→ 24-cross-account-access（FP-4）→ 25-sso（FP-5）→ 30-network（基础网络）→ 35-connectivity（FP-6）→ 40-security（基础 Policy + FP-2 护栏）→ 45-compliance（FP-7）→ 50-logging（基础日志）→ 55-delegation（FP-8）→ 60-finops（预算/标签）→ 70-workload-onboarding。

每完成一个功能点：更新 [README 实现状态](../README.md) 与 [tests/README](../tests/README.md)，提交并进入下一轮。
