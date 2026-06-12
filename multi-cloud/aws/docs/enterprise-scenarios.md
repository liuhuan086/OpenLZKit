# AWS 企业级深化路线图

> 在 MVP 七域（org / identity / network / security / logging / finops / workload-onboarding）之上，把 AWS Landing Zone 做成**企业级标准模范**。
> 本文是深化阶段的权威来源（文档先行）：按功能点（Feature Point, FP）设计 → 实现 → 测试 → 提交，逐轮推进。
> 每个 FP 都遵循仓库统一标准：module + live + README + 测试，`terraform fmt + validate` 通过；可策略校验的部分补 Conftest 用例。

## 设计原则（企业级）

- **账号即隔离边界**：用 AWS Organizations 的 OU + Account 表达组织、环境、业务部门和安全域，而不是把资源堆在一个账号里。
- **护栏前移**：用 Service Control Policies（SCP）在组织层禁止高危操作，用 AWS Config / Security Hub 做运行时发现。
- **人走 IAM Identity Center，机器走 OIDC/STS**：人员通过 Identity Center permission set 获得临时访问；CI/CD 通过 OIDC assume role，杜绝长期 access key。
- **集中而隔离**：日志、审计、安全、网络、共享服务进入专用账号；管理账号只做组织编排。
- **可委派**：AWS Config、Security Hub、GuardDuty、Firewall Manager、IAM Identity Center、RAM 等能力委派给专用成员账号。
- **Control Tower/AFT 兼容**：本仓库提供可学习和可测试的 Terraform Blueprint，生产中可与 Control Tower / Account Factory for Terraform 对接，而不是替代所有官方托管能力。

## 现状（MVP 骨架）

| 域 | 状态 | 说明 |
|---|---|---|
| docs | 🟡 | 已有基础设计文档，多个文件仍是 TODO |
| modules/live/examples/tests | 🟡 | FP-1、FP-2、FP-3、FP-4、FP-5、FP-6、FP-7、FP-8 已有第一版，其余功能点待补齐 |
| policies | 🟡 | FP-2 已有 Organizations guardrail；其余 plan-time guardrails 待补齐 |

## 深化功能点（计划）

### FP-1 多账号管理：组织与账号工厂（Organizations / Account Vending）

- **状态**：✅ 第一版已实现（`modules/org`、`modules/account-factory`、`live/10-org`、`examples/basic`、`examples/account-factory`）。
- **场景**：平台团队按标准流程创建/导入业务、环境、安全、网络、共享服务账号，放入对应 OU，强制命名、email、标签和生命周期约束。
- **AWS 能力**：AWS Organizations OU / Account；生产可对接 Control Tower Account Factory 或 AFT。
- **Terraform**：`aws_organizations_organizational_unit`、`aws_organizations_account`。
- **落地**：`modules/org`（OU 层级）与 `modules/account-factory`（账号售卖，默认空 map，避免误创建真实账号）；在 `live/10-org` 消费。
- **验收**：OU key 可稳定引用；账号创建显式启用；输出 OU/account ids；fmt+validate 通过。

### FP-2 组织护栏：SCP 与 Tag Policy

- **状态**：✅ 第一版已实现（`modules/org-policies`、`live/40-security`、`examples/org-policies`、`policies/organizations.rego`）。
- **场景**：组织层禁止高危动作：关闭 CloudTrail/Config/GuardDuty，离开允许 Region，删除日志归档，创建 root/user access key，公网开放高危端口。
- **AWS 能力**：Organizations Service Control Policy；Organizations Tag Policy。
- **Terraform**：`aws_organizations_policy`、`aws_organizations_policy_attachment`。
- **落地**：`modules/org-policies`；在 `live/40-security` 附加到 root/OU/account。
- **验收**：策略 JSON 合法；区分 SCP 与 Tag Policy；可按 OU/account 附加；Conftest 校验禁止过宽 deny 例外。

### FP-3 业务部门管理（Departments / Business Units）

- **状态**：✅ 第一版已实现（`modules/department`、`live/15-departments`、`examples/departments`、`docs/department-model.md`）。
- **场景**：不同业务部门各自的 OU + 部门级 SCP/Tag Policy + 部门管理员角色 + 成本归属标签。
- **AWS 能力**：Organizations OU、SCP、Tag Policy、IAM role。
- **Terraform**：组合 OU、policy attachment、`aws_iam_role`、`aws_iam_role_policy_attachment`。
- **落地**：`modules/department`；在 `live/15-departments` 消费。
- **验收**：每个部门一套 OU/role/tag baseline；trust 限定到平台/SSO/部门主体；fmt+validate 通过。

### FP-4 跨账号访问（Cross-account Access）

- **状态**：✅ 第一版已实现（`modules/cross-account-access`、`live/24-cross-account-access`、`examples/cross-account-access`、`docs/cross-account-access-model.md`、`policies/iam_trust.rego`）。
- **场景**：安全账号只读审计所有成员账号；CI/CD 从自动化账号 assume role 到工作负载账号；日志账号集中收集；网络账号管理 TGW。
- **AWS 能力**：IAM role trust policy、STS AssumeRole、OIDC federation、RAM Resource Share。
- **Terraform**：`aws_iam_role`、`aws_iam_role_policy_attachment`、`aws_iam_openid_connect_provider`、`aws_ram_resource_share`。
- **落地**：`modules/cross-account-access`，按 `{trusted_principals, external_id, oidc_conditions, permissions}` 声明角色与信任。
- **验收**：trust policy 有来源账号/外部 ID/OIDC 条件；最小权限；Conftest 正反例禁止 `Principal="*"`。

### FP-5 人员 SSO：IAM Identity Center

- **状态**：✅ 第一版已实现（`modules/identity-center`、`live/25-sso`、`examples/identity-center`、`docs/identity-model.md`）。
- **场景**：人员通过 IAM Identity Center 登录，按 permission set 分配到账号/OU，不在成员账号里建 IAM user。
- **AWS 能力**：IAM Identity Center permission set、account assignment；Identity Store group/user。
- **Terraform**：`aws_ssoadmin_permission_set`、`aws_ssoadmin_managed_policy_attachment`、`aws_ssoadmin_account_assignment`、`aws_identitystore_group`、`aws_identitystore_user`、`aws_identitystore_group_membership`。
- **落地**：`modules/identity-center`；在 `live/25-sso` 消费。
- **验收**：permission set 映射到统一角色模型；优先 group assignment；fmt+validate 通过。

### FP-6 网络互联：Transit Gateway / RAM

- **状态**：✅ 第一版已实现（`modules/connectivity`、`live/35-connectivity`、`examples/connectivity`、`docs/network-model.md`）。
- **场景**：Hub-Spoke 跨账号互联；prod↔shared 私网；sandbox↔prod 默认拒绝；跨账号共享 TGW。
- **AWS 能力**：Transit Gateway、TGW route table、VPC attachment、RAM Resource Share。
- **Terraform**：`aws_ec2_transit_gateway`、`aws_ec2_transit_gateway_route_table`、`aws_ec2_transit_gateway_vpc_attachment`、`aws_ec2_transit_gateway_route_table_association`、`aws_ec2_transit_gateway_route_table_propagation`、`aws_ram_resource_share`。
- **落地**：`modules/connectivity`；在 `live/35-connectivity` 消费。
- **验收**：route table 表达 prod/nonprod/sandbox/shared 隔离；sandbox 不传播到 prod；fmt+validate 通过。

### FP-7 集中合规：AWS Config / Security Hub / GuardDuty

- **状态**：✅ 第一版已实现（`modules/compliance`、`live/45-compliance`、`examples/compliance`、`docs/compliance-model.md`）。
- **场景**：跨账号持续检测未打标签、公开 S3、未加密 EBS/RDS、SG 公网高危、CloudTrail/Config 关闭等问题。
- **AWS 能力**：AWS Config recorder / aggregator / conformance pack；Security Hub；GuardDuty。
- **Terraform**：`aws_config_configuration_recorder`、`aws_config_configuration_aggregator`、`aws_config_conformance_pack`、`aws_securityhub_organization_admin_account`、`aws_guardduty_organization_admin_account`。
- **落地**：`modules/compliance`；在 `live/45-compliance` 消费（委派到 security/compliance account）。
- **验收**：托管规则覆盖标签/加密/公网/审计；与 plan-time Conftest 互补；fmt+validate 通过。

### FP-8 委派管理与资源共享（Delegated Admin / RAM）

- **状态**：✅ 第一版已实现（`modules/delegation`、`live/55-delegation`、`examples/delegation`、`docs/delegation-model.md`）。
- **场景**：把 Security Hub、GuardDuty、Config、Firewall Manager、IAM Access Analyzer 等能力委派给专用成员账号；共享 TGW/Subnet/License/AMI 等资源给业务账号。
- **AWS 能力**：Organizations delegated administrator；AWS RAM。
- **Terraform**：`aws_organizations_delegated_administrator`、`aws_ram_resource_share`、`aws_ram_principal_association`、`aws_ram_resource_association`。
- **落地**：`modules/delegation`；在 `live/55-delegation` 消费。
- **验收**：委派 service principal 精确；共享目标受限；fmt+validate 通过。

### FP-9 日志、安全湖与审计归档深化

- **场景**：组织级 CloudTrail、Config/SecurityHub/GuardDuty findings、VPC Flow Logs、S3 access logs、CloudWatch/Kinesis/Firehose 统一入 log archive/security lake。
- **AWS 能力**：CloudTrail organization trail、S3 Object Lock、KMS、CloudWatch Logs、Firehose、Security Lake（可选）。
- **Terraform**：`aws_cloudtrail`、`aws_s3_bucket`、`aws_s3_bucket_object_lock_configuration`、`aws_kms_key`、`aws_cloudwatch_log_group`、可选 Security Lake 资源。
- **落地**：扩展 `modules/logging`；在 `live/50-logging` 消费。
- **验收**：组织级 trail、集中加密、对象锁/保留期、防删除策略；fmt+validate 通过。

### FP-10 FinOps 与预算治理深化

- **场景**：强制成本标签、预算告警、异常检测、部门成本归集、sandbox 限额。
- **AWS 能力**：Organizations Tag Policy、AWS Budgets、Cost Anomaly Detection、Cost Categories。
- **Terraform**：`aws_budgets_budget`、`aws_ce_anomaly_monitor`、`aws_ce_anomaly_subscription`、`aws_ce_cost_category`。
- **落地**：扩展 `modules/finops`；在 `live/60-finops` 消费。
- **验收**：预算与异常检测可按部门/账号/env 维度声明；fmt+validate 通过。

## 推进顺序

FP-1 → FP-2 → FP-3 → FP-4 → FP-5 → FP-6 → FP-7 → FP-8 → FP-9 → FP-10。

先把"组织 + 账号 + 护栏 + 部门 + 跨账号 + SSO"这条人/账号主线打通（FP-1~5），再做网络与运行时合规（FP-6~7），随后委派与共享（FP-8），最后深化日志与 FinOps（FP-9~10）。

每完成一个 FP：更新 [README 实现状态](../README.md) 与 [tests/README](../tests/README.md)，提交并进入下一轮。
