# Google Cloud 企业级深化路线图

> 把 GCP Landing Zone 做成**企业级标准模范**，与阿里云 / AWS / Azure 保持同一套治理标准，但严格使用 GCP 原生模型（Organization → Folder → Project / Organization Policy / IAM + Cloud Identity / Workload Identity Federation / Shared VPC），不照搬其他云。
> 本文是 GCP 实现阶段的权威来源（文档先行）：按功能点（Feature Point, FP）设计 → 实现 → 测试 → 提交，逐轮推进。
> 每个 FP 都遵循仓库统一标准：module + live + README + 测试，通过 CI 五道门禁（`fmt` / `validate` / `tflint` / `checkov` / `conftest`）。

## 设计原则（企业级）

- **Folder + Project 即隔离边界**：用 Folder 层级表达组织/环境/业务部门，用 Project 承载资源与计费边界，而不是把资源堆在一个 Project 里。
- **护栏前移**：用 **Organization Policy**（约束/自定义约束）在组织或 Folder 层禁止高危配置，等价于 AWS SCP / 阿里云管控策略 / Azure Policy。
- **人走 Cloud Identity 组，机器走 Workload Identity Federation / 服务账号模拟**：人员通过组获得 IAM，自动化通过 WIF 联合 GitHub OIDC 换取短期令牌或模拟服务账号，杜绝长期 SA key。
- **集中而隔离**：日志（聚合 Log Sink → 日志项目）、安全（Security Command Center）、网络（Shared VPC 宿主项目）、计费导出集中，但 IAM 最小授权、彼此隔离。
- **可委派**：在 Folder 层用 IAM 授予专用团队管理权；用 Shared VPC service project 把网络能力委派给业务项目。

## 基础域（与其他云对齐，作为 FP 的底座）

| 域 | GCP 实现 | 关键资源 |
|---|---|---|
| org | Folder 层级 | `google_folder` |
| identity | 自定义 IAM 角色 + 绑定 | `google_organization_iam_custom_role`、`google_*_iam_member` |
| network | Shared VPC + 默认拒绝防火墙 | `google_compute_network`、`google_compute_subnetwork`、`google_compute_firewall` |
| security | Organization Policy 安全基线 | `google_org_policy_policy` / `google_folder_organization_policy` |
| logging | 聚合 Log Sink → 日志项目/BigQuery | `google_logging_folder_sink`、`google_logging_project_bucket_config` |
| finops | 预算 + 标签/标记 | `google_billing_budget` |
| workload-onboarding | Project + 服务账号 + IAM + 标签 | `google_project`、`google_service_account` |

`live/00-bootstrap` 提供远程 state（GCS 后端）、seed/平台项目，以及 GitHub OIDC 的 Workload Identity Federation（`google_iam_workload_identity_pool` + provider）与 CI 服务账号。

## 深化功能点（计划）

### FP-1 多账号管理：项目工厂（Project Factory）

- **场景**：平台团队按标准流程批量创建业务/环境 Project，落入对应 Folder，强制标签与命名、关联计费账号。
- **GCP 能力**：Folder + Project（关联 billing account、绑定到 Folder）。
- **Terraform**：`google_folder`、`google_project`（`folder_id`、`billing_account`、`labels`）。
- **落地**：`modules/project-factory`；在 `live/10-org` 消费（默认空 map，创建 Project 有计费影响，需显式开启）。
- **验收**：从 Folder key 映射创建 Project；标签含 FinOps 标签集；fmt+validate 通过。

### FP-2 组织护栏：Organization Policy（SCP 等价）

- **场景**：组织层禁止高危——资源地域白名单、禁止 SA key 创建、禁止外网 IP、禁止公开存储桶、要求 OS Login。
- **GCP 能力**：Organization Policy 约束（布尔/列表约束）与自定义约束。
- **Terraform**：`google_org_policy_policy`、`google_folder_organization_policy`、`google_org_policy_custom_constraint`。
- **落地**：`modules/org-policies`；在 `live/40-security` 附加到组织/指定 Folder。
- **验收**：约束规则有效；按 enforce/allow/deny 声明；可附加到 Folder；Conftest 校验约束 JSON 结构。

### FP-3 业务部门管理（Departments）

- **场景**：每个业务部门一个 Folder + 部门级 Org Policy + 部门 IAM 角色边界 + 部门预算与成本标签。
- **GCP 能力**：Folder + Org Policy + IAM binding + Budget 组合。
- **Terraform**：`google_folder`、`google_folder_organization_policy`、`google_folder_iam_member`、`google_billing_budget`。
- **落地**：`modules/department`；在 `live/15-departments` 消费。
- **验收**：每个部门一套隔离边界；部门角色 scope 限定到部门 Folder；fmt+validate 通过。

### FP-4 跨项目访问（Cross-project Access）

- **场景**：安全项目只读审计所有项目；CI/CD 用 WIF/服务账号模拟在工作负载项目 apply；日志集中收集。
- **GCP 能力**：跨项目 IAM 绑定、服务账号模拟、Workload Identity Federation。
- **Terraform**：`google_project_iam_member`、`google_service_account`、`google_service_account_iam_member`、`google_iam_workload_identity_pool(_provider)`。
- **落地**：`modules/cross-account-access`；在 `live/24-cross-account-access` 消费。
- **验收**：IAM 绑定 scope 最小且显式；机器身份用 WIF/模拟，不下载 SA key；正反 Conftest 用例（禁止 `roles/owner`@组织）。

### FP-5 人员访问：Cloud Identity 组 + IAM（SSO 等价）

- **场景**：人员通过 Cloud Identity 组获得 IAM，不在项目内建本地用户/长期凭据。
- **GCP 能力**：Cloud Identity 组、组到 IAM 角色的 scope 化绑定。
- **Terraform**：`google_cloud_identity_group`、`google_*_iam_member`（成员为组）。
- **落地**：`modules/identity-groups`；在 `live/25-sso` 消费。
- **验收**：组映射到统一角色模型；绑定到 Folder/Project scope；fmt+validate 通过。

### FP-6 网络互联（Shared VPC / Network Connectivity Center）

- **场景**：Shared VPC 宿主项目集中网络；业务项目作为 service project 接入；跨 VPC 互联用 NCC；sandbox↔prod 默认隔离。
- **GCP 能力**：Shared VPC（host/service project）、VPC Peering、Network Connectivity Center hub/spoke。
- **Terraform**：`google_compute_shared_vpc_host_project`、`google_compute_shared_vpc_service_project`、`google_network_connectivity_hub`、`google_network_connectivity_spoke`。
- **落地**：`modules/connectivity`；在 `live/35-connectivity` 编排 host/service 与 hub/spoke。
- **验收**：CIDR 不重叠；sandbox 项目不接入 prod 共享网络；fmt+validate 通过。

### FP-7 集中合规（Security Command Center）

- **场景**：运行时持续检测——公开资源、缺标签、弱配置、未加密——组织级汇总。
- **GCP 能力**：Security Command Center（来源、BigQuery 导出、通知）+ Org Policy 合规。
- **Terraform**：`google_scc_source`、`google_scc_organization_scc_big_query_export`、`google_scc_notification_config`。
- **落地**：`modules/compliance`；在 `live/45-compliance` 消费（委派到安全项目）。
- **验收**：SCC 导出/通知覆盖关键 finding 类别；与 plan-time Conftest 互补；fmt+validate 通过。

### FP-8 委派管理与共享（Folder 委派 / Shared VPC 接入）

- **场景**：在 Folder 层把网络/安全/合规管理委派给专用团队；把 Shared VPC 宿主网络共享给业务 service project。
- **GCP 能力**：Folder 级 IAM 委派；Shared VPC service project 关联；子网级 IAM。
- **Terraform**：`google_folder_iam_member`、`google_compute_shared_vpc_service_project`、`google_compute_subnetwork_iam_member`。
- **落地**：`modules/delegation`；在 `live/55-delegation` 消费。
- **验收**：委派角色最小且不含 `roles/owner`；共享接入受限到指定子网；fmt+validate 通过。

## 推进顺序

00-bootstrap → 10-org（基础 Folder + FP-1 项目工厂）→ 15-departments（FP-3）→ 20-identity（基础 IAM）→ 24-cross-account-access（FP-4）→ 25-sso（FP-5）→ 30-network（基础 Shared VPC）→ 35-connectivity（FP-6）→ 40-security（基础 Org Policy + FP-2 护栏）→ 45-compliance（FP-7）→ 50-logging（聚合日志）→ 55-delegation（FP-8）→ 60-finops（预算/标签）→ 70-workload-onboarding。

每完成一个功能点：更新 [README 实现状态](../README.md) 与 [tests/README](../tests/README.md)，提交并进入下一轮。
