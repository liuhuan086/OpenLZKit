# Live Stack 流程图

本图展示推荐部署顺序和 state 边界。每个 live stack 都应有独立 backend key 或等价 state 路径。

```mermaid
flowchart TD
  bootstrap["00-bootstrap<br/>远程 state、CI 身份、初始审计"]
  org["10-org<br/>组织层级与账号/项目/订阅售卖"]
  departments["15-departments<br/>业务部门边界"]
  identity["20-identity<br/>基础角色与权限边界"]
  crossAccess["24-cross-account-access<br/>自动化与安全跨账号访问"]
  sso["25-sso<br/>人员访问组与分配"]
  network["30-network<br/>VPC/VNet/网络基线"]
  connectivity["35-connectivity<br/>TGW、CEN/TR、CCN、Peering、Shared VPC"]
  security["40-security<br/>预防性护栏"]
  compliance["45-compliance<br/>运行时合规检测"]
  logging["50-logging<br/>审计与日志归档"]
  delegation["55-delegation<br/>委派管理与共享"]
  finops["60-finops<br/>标签、预算、成本责任"]
  onboarding["70-workload-onboarding<br/>团队交付与工作负载基线"]

  bootstrap --> org
  org --> departments
  org --> identity
  identity --> crossAccess
  identity --> sso
  org --> network
  network --> connectivity
  org --> security
  security --> compliance
  bootstrap --> logging
  security --> logging
  org --> delegation
  identity --> delegation
  org --> finops
  departments --> onboarding
  identity --> onboarding
  network --> onboarding
  logging --> onboarding
  finops --> onboarding
```

## State 边界规则

- Bootstrap state 与后续所有 stack 隔离。
- 组织与安全策略 state 不应和工作负载接入混在一起。
- 网络互联 state 与账号/项目/订阅售卖 state 分离。
- State 地址迁移需要迁移计划；如果改变架构边界，还需要更新 ADR。
