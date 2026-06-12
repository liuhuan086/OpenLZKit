# Alibaba Cloud 企业级深化路线图

> 在 MVP 七域（org / identity / network / security / logging / finops / workload-onboarding）之上，把阿里云 Landing Zone 做成**企业级标准模范**。
> 本文是深化阶段的权威来源（文档先行）：按功能点（Feature Point, FP）设计 → 实现 → 测试 → 提交，逐轮推进。
> 每个 FP 都遵循仓库统一标准：module + live + README + 测试，`terraform fmt + validate` 通过；可策略校验的部分补 Conftest 用例。

## 设计原则（企业级）

- **账号即隔离边界**：用 Resource Directory 的 folder + 成员账号表达组织、环境、业务部门，而不是把资源堆在一个账号里。
- **护栏前移**：用 Control Policy（管控策略，等价 AWS SCP）在组织层禁止高危操作，而不是事后检测。
- **人走 SSO，机器走 OIDC**：人员通过 CloudSSO 获取临时访问，自动化通过 OIDC/STS 假设角色，杜绝长期 AccessKey。
- **集中而隔离**：日志、审计、网络、合规集中到专用账号，但彼此权限隔离、最小授权。
- **可委派**：安全/审计/合规能力委派给专用成员账号（delegated administrator），管理账号只做编排。

## 现状（MVP 已完成）

| 域 | 模块 | 说明 |
|---|---|---|
| org / identity / network / security / logging / finops / workload-onboarding | ✅ | 见 [README 实现状态](../README.md) |
| policies | ✅ | Conftest/Rego 护栏（标签 / 公网入站 / 加密） |

## 深化功能点（计划）

### FP-1 多账号管理：账号工厂（Account Vending）

- **状态**：✅ 已实现第一版（`modules/account-factory` + `live/10-org` 空输入接入 + 静态示例）。
- **场景**：平台团队按标准流程批量创建业务/环境成员账号，落入对应 folder，强制标签与命名。
- **阿里云能力**：Resource Directory 成员账号。
- **Terraform**：`alicloud_resource_manager_account`（`display_name`、`folder_id`、`tags`）。
- **落地**：`modules/account-factory`；在 `live/10-org` 消费（默认空 map，创建账号有计费影响，需显式开启）。
- **验收**：从 folder key 映射创建账号；标签包含 FinOps 标签集；fmt+validate 通过。

### FP-2 组织护栏：管控策略（Control Policies / SCP 等价）

- **状态**：✅ 已实现第一版（`modules/control-policies` + `live/40-security` 空输入接入 + 静态示例）。
- **场景**：组织层禁止高危操作——关闭 ActionTrail、超出允许地域、创建长期 AccessKey、公网暴露高危端口、删除日志归档。
- **阿里云能力**：Resource Directory Control Policy（管控策略）。
- **Terraform**：`alicloud_resource_manager_control_policy` + `alicloud_resource_manager_control_policy_attachment`。
- **落地**：`modules/control-policies`；在 `live/40-security` 附加到 Root / 指定 folder。
- **验收**：策略文档为合法 JSON；按 effect_scope（RAM/Resource）声明；可附加到目标；Conftest 校验策略 JSON 结构。

### FP-3 业务部门管理（Departments）

- **状态**：✅ 已实现第一版（`modules/department` + `live/15-departments` + 静态示例）。
- **场景**：不同业务部门各自的 folder + 部门级管控策略 + 部门 RAM 角色边界 + 部门成本归属（cost_center/owner 标签）。
- **阿里云能力**：folder + control policy + RAM role + tag policy 组合。
- **Terraform**：`alicloud_resource_manager_folder`、`alicloud_ram_role`、`alicloud_resource_manager_control_policy_attachment`、`alicloud_tag_policy`、`alicloud_tag_policy_attachment`。
- **落地**：`modules/department`（编排 folder + 部门角色 + 部门管控策略附加 + 部门标签策略）；在 `live/15-departments` 消费。
- **验收**：每个部门一套隔离边界；部门角色 trust 限定到部门主体；fmt+validate 通过。

### FP-4 跨账号访问（Cross-account Access）

- **状态**：✅ 已实现第一版（`modules/cross-account-access` + `live/24-cross-account-access` + 静态示例）。
- **场景**：安全账号只读审计所有成员账号；CI/CD 从自动化账号假设角色到工作负载账号 apply；日志账号集中收集。
- **阿里云能力**：RAM 角色跨账号信任 + STS AssumeRole；可选 Resource Share 共享资源。
- **Terraform**：`alicloud_ram_role`（跨账号 trust）、`alicloud_resource_manager_resource_share` + `shared_target`。
- **落地**：`modules/cross-account-access`（按 `{source_account, target_role, permissions, conditions}` 声明角色与信任）。
- **验收**：trust 文档限定来源账号/条件；最小权限；正反 Conftest 用例（禁止过宽 trust）。

### FP-5 人员 SSO（CloudSSO 访问）

- **状态**：✅ 已实现第一版（`modules/sso` + `live/25-sso` + 静态示例）。
- **场景**：人员通过 CloudSSO 登录，按权限配置（permission set）分配到账号，不在成员账号里建 RAM 用户。
- **阿里云能力**：CloudSSO 目录、用户/组、访问配置、访问分配。
- **Terraform**：`alicloud_cloud_sso_directory`、`alicloud_cloud_sso_group`、`alicloud_cloud_sso_user`、`alicloud_cloud_sso_user_attachment`、`alicloud_cloud_sso_access_configuration`、`alicloud_cloud_sso_access_assignment`、`alicloud_cloud_sso_access_configuration_provisioning`。
- **落地**：`modules/sso`；在 `live/25-sso` 消费。
- **验收**：访问配置映射到统一角色模型；分配到 folder/account；fmt+validate 通过。

### FP-6 网络互联（CEN / Transit Router）

- **状态**：✅ 已实现第一版（`modules/connectivity` + `live/35-connectivity` + 静态示例）。
- **场景**：Hub-Spoke 跨账号互联；prod↔shared 私网；sandbox↔prod 默认拒绝；跨账号网络授权。
- **阿里云能力**：CEN 实例 + Transit Router + VPC 挂载 + 路由策略 + 跨账号授权。
- **Terraform**：`alicloud_cen_instance`、`alicloud_cen_transit_router`、`alicloud_cen_transit_router_route_table`、`alicloud_cen_transit_router_vpc_attachment`、`alicloud_cen_transit_router_grant_attachment`、`alicloud_cen_transit_router_route_table_association`、`alicloud_cen_transit_router_route_table_propagation`、`alicloud_cen_transit_router_route_entry`。
- **落地**：`modules/connectivity`；在 `live/35-connectivity` 编排 hub/spoke 挂载。
- **验收**：CIDR 不重叠；sandbox→prod 路由拒绝；fmt+validate 通过。

### FP-7 集中合规（Cloud Config）

- **状态**：✅ 已实现第一版（`modules/compliance` + `live/45-compliance` + 静态示例）。
- **场景**：运行时持续检测——未打标签、公网 OSS、未加密磁盘、SG 公网高危——跨账号聚合。
- **阿里云能力**：Cloud Config 规则 + 多账号聚合器。
- **Terraform**：`alicloud_config_configuration_recorder`、`alicloud_config_aggregator`、`alicloud_config_aggregate_config_rule`、`alicloud_config_aggregate_compliance_pack`、`alicloud_config_aggregate_delivery`。
- **落地**：`modules/compliance`；在 `live/45-compliance` 消费（委派到安全账号）。
- **验收**：托管规则集覆盖标签/加密/公网；与 plan-time Conftest 互补；fmt+validate 通过。

### FP-8 委派管理与资源共享（Delegated Admin / Resource Share）

- **场景**：把审计、合规、网络能力委派给专用成员账号；共享 Transit Router / VPC 给业务账号。
- **阿里云能力**：Resource Directory delegated administrator；Resource Share。
- **Terraform**：`alicloud_resource_manager_delegated_administrator`、`alicloud_resource_manager_resource_share` + `shared_resource` + `shared_target`。
- **落地**：扩展 `modules/cross-account-access` 或新增 `modules/delegation`。
- **验收**：委派范围最小；共享目标受限；fmt+validate 通过。

## 推进顺序

FP-1 → FP-2 → FP-3 → FP-4 → FP-5 → FP-6 → FP-7 → FP-8。
先把"多账号 + 护栏 + 部门 + 跨账号 + SSO"这条人/账号主线打通（FP-1~5），再做网络与合规（FP-6~7），最后委派与共享（FP-8）。

每完成一个 FP：更新 [README 实现状态](../README.md) 与 [tests/README](../tests/README.md)，提交并进入下一轮。
