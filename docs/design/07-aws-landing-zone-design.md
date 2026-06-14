# AWS Landing Zone 设计说明

## 1. 定位

AWS 是 OpenLZKit 的第二朵重点云。它用于展示全球企业中最典型的多账号治理、集中审计、组织级 guardrails 和基于短期凭证的 IaC 交付模型。

AWS 设计必须基于 AWS Organizations、Control Tower、IAM Identity Center、SCP、CloudTrail、Config、Security Hub、Transit Gateway 等原生能力，不能把 Azure 管理组、GCP Folder 或阿里云资源目录的模型硬套进来。

## 2. 核心组成

| 能力域 | AWS 相关能力 | OpenLZKit 输出 |
|---|---|---|
| 组织与账号 | AWS Organizations、OU、Account、Control Tower/AFT | OU 规划、账号矩阵、账号工厂说明 |
| 身份与权限 | IAM、IAM Identity Center、Permission Set、IAM Role | 角色矩阵、权限边界、跨账号访问说明 |
| 组织护栏 | SCP、Control Tower Controls、AWS Config Rules | 组织策略基线、例外机制、策略测试 |
| 网络 | VPC、Subnet、Security Group、NACL、Transit Gateway、Cloud WAN | CIDR 规划、Hub-Spoke/集中网络设计 |
| 日志审计 | CloudTrail、CloudWatch Logs、AWS Config、S3 Log Archive | 集中日志账号、审计留存、告警基线 |
| 安全 | Security Hub、GuardDuty、KMS、IAM Access Analyzer | 安全基线、检测项、风险报告 |
| 成本 | Cost Explorer、Budgets、Cost Categories、Tags | 成本标签规则、预算阈值、成本归因 |

## 3. 推荐账号结构

```text
management account
├── Security OU
│   ├── log-archive account
│   └── audit/security-tooling account
├── Infrastructure OU
│   ├── network account
│   └── shared-services account
├── Workloads OU
│   ├── dev account
│   ├── staging account
│   └── prod account
└── Sandbox OU
    └── sandbox account
```

设计原则：

1. Management account 不承载业务 workload。
2. 日志归档账号独立，业务账号不能修改归档策略。
3. 安全审计账号独立，默认只读跨账号审计。
4. 网络账号集中管理 Transit Gateway、共享出口、DNS 和连接。
5. 生产、非生产和 sandbox 使用独立账号与 state。

## 4. 身份与权限设计

人员访问优先走 IAM Identity Center 或企业 IdP Federation，再映射到 AWS Permission Set / IAM Role。机器访问优先使用 OIDC + AssumeRole，不把长期 Access Key 作为默认方案。

| 身份 | 建议机制 | 关键约束 |
|---|---|---|
| platform-team | IAM Identity Center Permission Set | 生产环境 JIT/审批，限制高危动作 |
| security-team | SecurityAudit / ReadOnlyAccess + 自定义审计权限 | 只读日志、安全服务和配置 |
| network-team | 网络账号 scoped IAM Role | 管理 TGW、VPC、DNS，不管理业务数据 |
| github-actions-plan | OIDC -> IAM Role | 只读、读取 state、生成 plan |
| github-actions-apply | OIDC -> IAM Role | 限定 repo、branch、environment，apply 需审批 |
| break-glass | 独立高权限角色或账号 | MFA、强告警、定期演练 |

跨账号访问使用目标账号 IAM Role 的 trust policy 信任管理账号、自动化账号或 OIDC provider，并通过 CloudTrail 记录 AssumeRole 与后续操作。

## 5. 网络设计

推荐集中网络账号承载 Hub-Spoke：

```text
network account
└── transit gateway / cloud wan core
    ├── shared services vpc
    ├── dev workload vpc
    ├── staging workload vpc
    └── prod workload vpc
```

关键原则：

- CIDR 统一规划，跨账号、跨区域、跨云不重叠。
- prod、non-prod、sandbox 默认不互通。
- VPC Flow Logs 默认开启并送往集中日志位置。
- 公网入口必须通过 ALB/NLB/API Gateway/CloudFront/WAF 等受控入口。
- 私网访问 AWS 服务优先使用 VPC Endpoint。

## 6. 安全 Guardrails

AWS 组织级 guardrails 至少覆盖：

- 禁止关闭 CloudTrail、Config、GuardDuty 等审计和检测能力。
- 限制 root 用户和高权限 IAM 操作。
- 禁止未加密存储和未授权公网暴露。
- 强制标签：`owner`、`env`、`cost_center`、`project`。
- 限制允许区域，sandbox 可设置更严格预算和资源边界。
- 生产账号 apply 必须走受保护环境审批。

高风险默认值必须默认关闭或显式声明例外，例外必须包含 owner、原因、到期时间和补偿控制。

## 7. 日志审计

推荐做法：

- 组织级 CloudTrail 写入 log archive account。
- AWS Config 聚合到 audit/security account。
- VPC Flow Logs、ALB/NLB 日志、WAF 日志集中存储。
- Security Hub/GuardDuty 发现项集中到安全账号。
- 关键操作告警：root 使用、SCP 变更、CloudTrail 变更、KMS key 变更、IAM 高权限变更。

日志账号的存储桶必须开启版本控制、加密、最小权限 bucket policy 和保留策略。

## 8. 成本治理

AWS 成本治理至少包括：

- 账号级预算和告警。
- 必填标签与 Cost Categories。
- sandbox 低预算阈值和自动清理候选规则。
- 对 NAT Gateway、公网 IP、GPU、大规格实例、跨区流量做重点告警。
- 月度成本归因报告按 account、OU、env、cost_center 聚合。

## 9. CI/CD 与 State 策略

Terraform state 按 `cloud + environment + layer + unit` 拆分。AWS 后端可以使用 S3 + DynamoDB Lock，S3 bucket 开启加密、版本控制和访问日志。

推荐流程：

```text
PR -> terraform fmt -> validate -> tflint -> checkov -> conftest
   -> plan artifact -> 人工审核 -> 受保护环境 apply -> 审计记录归档
```

CI/CD 角色分为 plan 和 apply，生产 apply 必须绑定 GitHub Environment approval 或等价审批机制。

## 10. 从 0 到 1 部署步骤

1. 准备 management account，启用 Organizations/Control Tower 或等价组织基线。
2. 创建 Security、Infrastructure、Workloads、Sandbox OU。
3. 创建 log archive、audit/security、network、shared-services 和 workload 账号。
4. 配置 IAM Identity Center、Permission Sets 和跨账号角色。
5. 开启组织级 CloudTrail、Config、GuardDuty/Security Hub 聚合。
6. 部署集中网络账号的 VPC、Transit Gateway、DNS 和出口控制。
7. 配置 SCP、标签策略、预算和策略即代码测试。
8. 接入第一个 workload account，并通过 CI/CD plan/apply 验证闭环。

## 11. 常见坑与解决方案

| 常见坑 | 风险 | 标准解法 |
|---|---|---|
| 使用 root 或 management account 日常操作 | 审计和权限风险极高 | 使用 IAM Identity Center、Role、MFA 和 break-glass 流程 |
| 所有环境放在一个账号 | 爆炸半径过大 | 按 dev/staging/prod/sandbox 拆账号和 state |
| 没有 log archive account | 业务账号可篡改审计 | 独立日志账号 + 组织级 CloudTrail |
| Trust policy 过宽 | 任意 repo 或身份可 AssumeRole | 限制 OIDC subject、audience、branch、environment |
| SCP 一次性过严 | 阻断 bootstrap 或修复操作 | 分阶段启用，配例外和 break-glass |
| NAT Gateway 无治理 | 成本不可控 | 标签、预算、流量告警和架构评审 |

## 12. MVP、V1、V2 范围

| 阶段 | 范围 |
|---|---|
| MVP | 组织/OU/账号骨架、基础身份、集中日志、基础网络、基础 SCP、README/示例/测试 |
| V1 | 账号工厂、IAM Identity Center 深化、跨账号访问、合规聚合、FinOps、工作负载接入闭环 |
| V2 | 多区域网络、Cloud WAN、自动成本报告、更多安全服务聚合、企业交付模板 |
