# 多云 Landing Zone 概念映射

## 1. 说明

OpenLZKit 不把不同云厂商的概念强行视为完全等价，而是做“架构级映射”。

项目当前优先级：

1. 阿里云 Alibaba Cloud
2. AWS
3. 腾讯云 Tencent Cloud
4. Azure
5. Google Cloud

Azure 和 Google Cloud 保留为后续扩展云，不从目录、schema、adapter 或文档中删除。

---

## 2. 核心概念映射

| OpenLZKit 通用概念 | 阿里云 | AWS | 腾讯云 | Azure | Google Cloud |
|---|---|---|---|---|---|
| Organization | Resource Directory | AWS Organizations | Tencent Cloud Organization | Tenant / Management Group hierarchy | Organization |
| Management Account | 管理账号 | Management Account | 组织管理账号 | Tenant Root / Platform Management Group | Organization Admin |
| Folder / OU | 资源夹 | Organizational Unit | 组织目录结构 | Management Group | Folder |
| Resource Container | 成员账号 / 资源账号 | Account | 成员账号 | Subscription | Project |
| Human Identity | RAM 用户/用户组 | IAM Identity Center / IAM User | CAM 用户/用户组 | Entra ID / Azure RBAC | Cloud IAM / Workforce Identity Federation |
| Machine Identity | RAM Role / STS | IAM Role / STS / OIDC | CAM Role / 临时密钥 | Managed Identity / Federated Credential | Service Account / Workload Identity Federation |
| Network | VPC / vSwitch | VPC / Subnet | VPC / Subnet | VNet / Subnet | VPC Network / Subnet |
| Hub-Spoke | CEN / Transit Router | Transit Gateway | CCN | Hub VNet / Virtual WAN | Shared VPC / Network Connectivity Center |
| Audit Log | ActionTrail / SLS | CloudTrail / CloudWatch Logs | CloudAudit / CLS | Activity Log / Log Analytics | Cloud Audit Logs / Logging Sink |
| Monitoring | CloudMonitor | CloudWatch | Cloud Monitor | Azure Monitor | Cloud Monitoring |
| Policy | RAM Policy / 资源目录管控策略 | IAM Policy / SCP | CAM Policy | Azure Policy / RBAC | Organization Policy / IAM Policy |
| Cost | 费用中心、标签、预算 | Budgets、Cost Explorer、Tags | 费用中心、标签、预算 | Cost Management / Budgets | Cloud Billing / Budgets |

---

## 3. 不能强行统一的点

- 阿里云 RAM、AWS IAM、腾讯云 CAM、Azure RBAC、Google Cloud IAM 的策略语义和资源标识格式不同。
- AWS SCP、阿里云资源目录管控策略、腾讯云组织策略、Azure Policy、Google Cloud Organization Policy 的覆盖范围和执行模型不同。
- 网络互联产品不同：阿里云 CEN/Transit Router、AWS Transit Gateway、腾讯云 CCN、Azure Virtual WAN、Google Cloud NCC/Shared VPC 不能简单替换。
- 日志产品不同，集中审计的开通方式和成本模型不同。
- 计费和预算能力差异较大，OpenLZKit 只能先做统一成本标签和预算阈值模型。

---

## 4. 推荐处理方式

1. 核心 schema 只描述云无关意图。
2. provider adapter 负责具体映射。
3. 文档生成必须标记“不完全等价”的地方。
4. IaC 生成只生成对应云厂商模板，不生成跨云混合 root module。
5. 测试用例必须覆盖阿里云、AWS、腾讯云、Azure、GCP 各自的差异场景。
