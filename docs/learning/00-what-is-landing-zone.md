# 什么是 Landing Zone

## 1. 简单定义

Landing Zone 可以理解为“企业上云之前先搭好的标准地基”。

它不是某一台服务器、某一个 Kubernetes 集群、某一个 VPC，也不是单纯的 Terraform 模块。它是一套包含账号结构、身份权限、网络、安全、日志、审计、成本、自动化和治理规则的云基础环境。

业务应用部署到云上之前，应该先落在这个受控、可审计、可扩展的基础环境里。

## 2. 它解决什么问题

### 2.1 账号隔离

不同业务、环境、团队应该分开管理。例如：

- 安全账号
- 日志账号
- 网络账号
- 共享服务账号
- 开发账号
- 测试账号
- 生产账号
- 沙箱账号

这样可以降低爆炸半径。某个开发环境被误删、被攻击、超预算，不应该影响生产环境。

### 2.2 权限治理

Landing Zone 会预先定义：

- 谁可以创建资源。
- 谁可以看日志。
- 谁可以改网络。
- 谁可以部署生产。
- 谁可以临时提权。
- CI/CD 用什么身份。

### 2.3 网络标准化

它会定义：

- 每个环境用什么 CIDR。
- 是否使用 Hub-Spoke。
- 是否允许跨云互联。
- 出口流量从哪里走。
- 生产和沙箱是否隔离。
- 私网访问、公网访问如何控制。

### 2.4 安全和审计

它会默认启用：

- 审计日志
- 配置变更记录
- 安全告警
- 加密要求
- 公网访问限制
- 关键操作告警
- root/admin 账号保护

### 2.5 成本治理

它会定义：

- 标签规范
- 成本中心
- 预算阈值
- 环境资源限制
- 沙箱自动清理
- 资源 owner

### 2.6 自动化交付

真正成熟的 Landing Zone 不应该完全靠人工创建，而应该通过 IaC、流水线和审批流程交付。

## 3. 各云厂商如何表达 Landing Zone

| 领域 | AWS | Azure | Google Cloud |
|---|---|---|---|
| 官方方案 | Control Tower / Organizations | Azure Landing Zone / CAF | Cloud Foundation / Landing Zone |
| 组织分组 | OU | Management Group | Folder |
| 资源容器 | Account | Subscription | Project |
| 策略 | SCP / Controls | Azure Policy | Organization Policy |
| 身份 | IAM / IAM Identity Center | Microsoft Entra ID / RBAC | Cloud IAM / Cloud Identity |
| 网络 | VPC / Transit Gateway | VNet / Hub-Spoke / Virtual WAN | VPC / Shared VPC |
| 日志 | CloudTrail / Config / CloudWatch | Monitor / Log Analytics | Cloud Logging / Audit Logs |

## 4. Landing Zone 不是一次性项目

Landing Zone 会随着企业成熟度演进：

1. 单账号阶段：只是为了跑业务。
2. 多账号阶段：开始隔离环境和业务。
3. 平台化阶段：账号/订阅/项目可以自助申请。
4. 治理阶段：安全、成本、合规策略自动化。
5. 产品化阶段：内部开发者平台对接 Landing Zone 能力。

## 5. 一个最小 Landing Zone 应该包含什么

最小可用版本至少包含：

- 账号/订阅/项目分层
- 身份和角色模型
- 网络 CIDR 与连接关系
- 日志和审计中心
- 标签与成本中心
- 安全基线
- IaC 状态管理
- CI/CD 认证方式
- 变更审批流程

## 6. 面试回答模板

如果面试官问“什么是 Landing Zone”，可以这样答：

> Landing Zone 是企业上云前的标准化基础环境。它不只是创建几个云账号，而是把多账号结构、身份权限、网络拓扑、安全基线、日志审计、成本标签、策略治理和 IaC 自动化统一设计好，让业务应用可以在一个可控、可审计、可扩展的环境中落地。AWS 里通常对应 Organizations/Control Tower，Azure 里对应 CAF/Azure Landing Zone，GCP 里对应 Cloud Foundation/Resource Hierarchy。
