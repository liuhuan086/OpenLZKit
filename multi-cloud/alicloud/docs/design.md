# Alibaba Cloud Landing Zone Design

## 1. 设计目标

- 建立企业级云上组织结构。
- 建立统一身份和权限模型。
- 建立安全、日志、网络、成本治理基线。
- 支持业务团队按标准流程接入。

## 2. 原生模型

Alibaba Cloud 的 Landing Zone 应基于其原生模型：Resource Directory / Cloud Governance Center。

关键能力包括：Resource Directory, folders, RAM, CloudSSO, ActionTrail, Config, CEN, OSS Log Archive。

## 3. 账号/订阅/项目结构

推荐分层：

- Management / Root。
- Security。
- Log Archive。
- Network / Connectivity。
- Shared Services。
- Sandbox。
- Workloads Dev。
- Workloads Staging。
- Workloads Prod。

## 4. 身份模型

- 人员访问走 SSO/Federation。
- 自动化访问走 OIDC/Federated Role。
- 工作负载访问走云原生服务角色/托管身份/服务账号。
- 禁止长期 Access Key 作为默认方案。

## 5. 网络模型

- 默认生产与非生产隔离。
- 集中网络账号/订阅/项目承载共享网络能力。
- 默认开启网络日志。
- 云服务优先私网访问。

## 6. 安全基线

- 操作审计开启。
- 配置审计开启。
- 日志集中归档。
- 存储和磁盘默认加密。
- 禁止公网高危暴露。
- 强制标签。

## 7. CI/CD

- PR 阶段执行 fmt、validate、lint、security scan、policy check。
- Merge 后允许 plan。
- Apply 需要环境审批。
- 生产环境单独保护。

## 8. 常见坑

- 直接使用主账号/Root 账号操作。
- 把所有环境放在一个账号/订阅/项目。
- Terraform state 不隔离。
- 手工创建资源后不纳管。
- 权限策略过大。
- 没有日志归档账号。
