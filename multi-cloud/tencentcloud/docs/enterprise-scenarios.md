# 腾讯云企业级深化路线图

> 把腾讯云 Landing Zone 做成**企业级标准模范**，与阿里云 / AWS / Azure / GCP 保持同一套治理标准，但严格使用腾讯云原生模型（TCO 组织 / 管控策略 / CAM / CCN / CloudAudit + CLS / CSIP），不照搬其他云。
> 本文是腾讯云实现阶段的权威来源（文档先行）：按功能点（Feature Point, FP）设计 → 实现 → 测试 → 提交，逐轮推进。
> 每个 FP 都遵循仓库统一标准：module + live + README + 测试，通过 CI 五道门禁（`fmt` / `validate` / `tflint` / `checkov` / `conftest`）。

## 设计原则（企业级）

- **组织节点 + 成员账号即隔离边界**：用 TCO（腾讯云组织）的 org node 层级表达组织/环境/业务部门，用成员账号承载资源与计费边界，而不是把资源堆在一个账号里。
- **护栏前移**：用 **管控策略（Org Manage Policy）** 在组织或节点层禁止高危操作，等价于 AWS SCP / 阿里云管控策略 / Azure Policy / GCP Org Policy。
- **人走 CAM SSO，机器走 OIDC/角色扮演**：人员通过 CAM 用户组 + SSO 身份获取访问，自动化通过 OIDC 联合或角色扮演（AssumeRole）换取临时密钥，杜绝长期 SecretKey。
- **集中而隔离**：日志（CloudAudit + CLS）、安全（CSIP）、网络（CCN）、合规集中到专用成员账号，但 CAM 最小授权、彼此隔离。
- **可委派**：用组织成员委派（delegated admin）把审计/安全能力委派给专用成员账号；用 org share unit 共享资源给业务账号。

## 基础域（与其他云对齐，作为 FP 的底座）

| 域 | 腾讯云实现 | 关键资源 |
|---|---|---|
| org | 组织节点层级 | `tencentcloud_organization_org_node` |
| identity | CAM 自定义策略 + 角色 | `tencentcloud_cam_policy`、`tencentcloud_cam_role`、`tencentcloud_cam_role_policy_attachment` |
| network | VPC + 子网 + 默认拒绝安全组 | `tencentcloud_vpc`、`tencentcloud_subnet`、`tencentcloud_security_group` |
| security | 管控策略安全基线 | `tencentcloud_organization_org_manage_policy` |
| logging | CloudAudit + CLS 日志集 | `tencentcloud_audit_track`、`tencentcloud_cls_logset`、`tencentcloud_cls_topic` |
| finops | 预算 + 分账标签 | `tencentcloud_billing_budget`、`tencentcloud_billing_allocation_tag` |
| workload-onboarding | CAM 角色 + 标签 + 资源 | `tencentcloud_cam_role`、`tencentcloud_tag` |

`live/00-bootstrap` 提供远程 state（COS 后端）、CI 角色与 CloudAudit 初始审计。

## 深化功能点（计划）

### FP-1 多账号管理：成员账号工厂（Member Account Vending）

- **场景**：平台团队按标准流程批量创建业务/环境成员账号，落入对应组织节点，强制标签与命名。
- **腾讯云能力**：TCO 组织节点 + 成员账号。
- **Terraform**：`tencentcloud_organization_org_node`、`tencentcloud_organization_org_member`。
- **落地**：`modules/account-factory`；在 `live/10-org` 消费（默认空 map，创建账号有计费影响，需显式开启）。
- **验收**：从节点 key 映射创建成员账号；标签含 FinOps 标签集；fmt+validate 通过。

### FP-2 组织护栏：管控策略（Org Manage Policy / SCP 等价）

- **场景**：组织层禁止高危——地域白名单、禁止关闭 CloudAudit、禁止公网高危端口、禁止删除日志、强制标签。
- **腾讯云能力**：组织管控策略（SERVICE_CONTROL_POLICY）。
- **Terraform**：`tencentcloud_organization_org_manage_policy`、`tencentcloud_organization_org_manage_policy_target`。
- **落地**：`modules/control-policies`；在 `live/40-security` 附加到根/指定节点。
- **验收**：策略文档为合法 JSON；按 effect（deny/allow）声明；可附加到节点；Conftest 校验策略 JSON 结构。

### FP-3 业务部门管理（Departments）

- **场景**：每个业务部门一个组织节点 + 部门级管控策略 + 部门 CAM 角色边界 + 部门预算与成本标签。
- **腾讯云能力**：org node + 管控策略附加 + CAM role + budget 组合。
- **Terraform**：`tencentcloud_organization_org_node`、`tencentcloud_organization_org_manage_policy_target`、`tencentcloud_cam_role`、`tencentcloud_billing_budget`。
- **落地**：`modules/department`；在 `live/15-departments` 消费。
- **验收**：每个部门一套隔离边界；部门角色 scope 限定到部门主体；fmt+validate 通过。

### FP-4 跨账号访问（Cross-account Access）

- **场景**：安全账号只读审计所有成员账号；CI/CD 从自动化账号扮演角色到工作负载账号 apply；日志集中收集。
- **腾讯云能力**：CAM 角色跨账号信任 + STS AssumeRole；org share unit 共享资源。
- **Terraform**：`tencentcloud_cam_role`（跨账号 trust document）、`tencentcloud_cam_role_policy_attachment`、`tencentcloud_organization_org_share_unit`。
- **落地**：`modules/cross-account-access`；在 `live/24-cross-account-access` 消费。
- **验收**：trust 文档限定来源账号/条件；最小权限；正反 Conftest 用例（禁止 `*` 主体过宽信任）。

### FP-5 人员访问：CAM 用户组 + SSO（CloudSSO 等价）

- **场景**：人员通过 CAM 用户组 + SSO 身份获取访问，按策略分配，不在成员账号里建长期用户。
- **腾讯云能力**：CAM 用户组、组策略附加、CAM 角色 SSO / 组织身份。
- **Terraform**：`tencentcloud_cam_group`、`tencentcloud_cam_group_policy_attachment`、`tencentcloud_cam_role_sso`。
- **落地**：`modules/identity-groups`；在 `live/25-sso` 消费。
- **验收**：组映射到统一角色模型；策略分配到组；fmt+validate 通过。

### FP-6 网络互联（CCN / Cloud Connect Network）

- **场景**：Hub-Spoke 跨账号互联；prod↔shared 私网；sandbox↔prod 默认隔离；跨账号网络授权。
- **腾讯云能力**：CCN（云联网）+ VPC 实例挂载 + 路由表。
- **Terraform**：`tencentcloud_ccn`、`tencentcloud_ccn_attachment`、`tencentcloud_ccn_route_table`。
- **落地**：`modules/connectivity`；在 `live/35-connectivity` 编排 CCN 与 VPC 挂载。
- **验收**：CIDR 不重叠；sandbox VPC 不挂载到 prod CCN；fmt+validate 通过。

### FP-7 集中合规（CloudAudit + CSIP）

- **场景**：运行时持续检测——公网暴露、未加密、缺标签、弱配置——跨账号汇总与审计跟踪。
- **腾讯云能力**：CloudAudit 跟踪集 + CSIP（云安全中心）风险中心 + CLS。
- **Terraform**：`tencentcloud_audit_track`、`tencentcloud_csip_risk_center`。
- **落地**：`modules/compliance`；在 `live/45-compliance` 消费（委派到安全账号）。
- **验收**：审计跟踪覆盖全地域读写事件；与 plan-time Conftest 互补；fmt+validate 通过。

### FP-8 委派管理与资源共享（Delegated Admin / Org Share Unit）

- **场景**：把审计/安全/网络管理委派给专用成员账号；用共享单元把网络/资源共享给业务账号。
- **腾讯云能力**：组织成员委派（auth policy attachment）；org share unit 资源共享。
- **Terraform**：`tencentcloud_organization_member_auth_policy_attachment`、`tencentcloud_organization_org_share_unit`、`tencentcloud_organization_org_share_unit_member`。
- **落地**：`modules/delegation`；在 `live/55-delegation` 消费。
- **验收**：委派范围最小；共享目标受限；fmt+validate 通过。

## 推进顺序

00-bootstrap → 10-org（基础 org node + FP-1 成员账号工厂）→ 15-departments（FP-3）→ 20-identity（基础 CAM）→ 24-cross-account-access（FP-4）→ 25-sso（FP-5）→ 30-network（基础 VPC）→ 35-connectivity（FP-6）→ 40-security（基础管控策略 + FP-2 护栏）→ 45-compliance（FP-7）→ 50-logging（CloudAudit + CLS）→ 55-delegation（FP-8）→ 60-finops（预算/标签）→ 70-workload-onboarding。

每完成一个功能点：更新 [README 实现状态](../README.md) 与 [tests/README](../tests/README.md)，提交并进入下一轮。
