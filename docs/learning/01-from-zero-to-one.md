# 从 0 到 1 设计一个多云 Landing Zone

## 第一步：明确目标和边界

先问 6 个问题：

1. 这套环境是学习演示、创业公司、还是大型企业？
2. 云厂商是单云还是多云？主云是哪一个？
3. 是否有生产业务？是否需要合规？
4. 是否已有账号、网络、域名、CI/CD、监控？
5. 是否允许自动创建账号/订阅/项目？
6. 是否有统一身份源，例如 AD、Entra ID、企业微信、飞书、LDAP？

对于个人开源项目，建议定位为：

> 支持多云建模、生成和校验，不强依赖真实企业主账号。

## 第二步：设计资源层级

### 阿里云推荐起点

```text
Resource Directory
├── Security Folder
│   ├── Audit Log Account
│   └── Security Tooling Account
├── Infrastructure Folder
│   ├── Network Account
│   └── Shared Services Account
├── Workloads Folder
│   ├── Dev Account
│   ├── Test Account
│   └── Prod Account
└── Sandbox Folder
    └── Sandbox Account
```

### AWS 推荐起点

```text
Root
├── Security OU
│   ├── Log Archive Account
│   └── Audit/Security Tooling Account
├── Infrastructure OU
│   ├── Network Account
│   └── Shared Services Account
├── Workloads OU
│   ├── Dev Account
│   ├── Test Account
│   └── Prod Account
└── Sandbox OU
    └── Sandbox Account
```

### 腾讯云推荐起点

```text
Organization
├── Security
│   ├── Audit Account
│   └── Security Tooling Account
├── Infrastructure
│   ├── Network Account
│   └── Shared Services Account
├── Workloads
│   ├── Dev Account
│   ├── Test Account
│   └── Prod Account
└── Sandbox
    └── Sandbox Account
```

### Azure 推荐起点

```text
Tenant Root Group
└── Intermediate Root
    ├── Platform
    │   ├── Identity Subscription
    │   ├── Management Subscription
    │   └── Connectivity Subscription
    ├── Landing Zones
    │   ├── Corp
    │   └── Online
    └── Sandbox
```

### GCP 推荐起点

```text
Organization
├── Common
│   ├── logging-project
│   ├── monitoring-project
│   └── cicd-project
├── Networking
│   └── shared-vpc-host-project
├── Workloads
│   ├── dev-folder
│   ├── test-folder
│   └── prod-folder
└── Sandbox
```

## 第三步：设计身份与角色

### 人类用户

- Platform Admin：管理基础平台，但不直接操作业务数据。
- Security Auditor：只读安全日志和配置。
- Network Admin：管理网络和连接。
- App Developer：只能管理自己应用环境。
- Finance Viewer：查看成本和预算。
- Break Glass Admin：紧急账号，强审计，平时禁用或极少使用。

### 机器身份

- CI/CD Planner：只允许 plan 和读取状态。
- CI/CD Deployer：只允许在指定环境 apply。
- Policy Bot：只读 plan JSON 并执行策略检查。
- Report Bot：读取 blueprint 和 plan，生成报告。

## 第四步：设计网络

推荐默认：

- 生产、测试、开发、沙箱使用不同 CIDR。
- hub 网络承载共享出口、安全设备、DNS、VPN/专线。
- spoke 网络承载业务。
- prod 与 sandbox 禁止直连。
- 跨云互联必须通过集中网络层，不允许业务账号之间随意 peering。

## 第五步：设计安全基线

最小基线：

- 审计日志集中存储。
- 所有账号启用配置变更记录。
- 禁止公开对象存储，除非显式声明例外。
- 生产环境强制加密。
- 高权限角色必须 MFA 或 JIT。
- CI/CD 使用 OIDC/WIF，不使用长期密钥。
- root/owner 账号不用于日常操作。

## 第六步：设计成本治理

- 每个资源容器必须有 owner 和 cost_center。
- sandbox 设置低预算和自动清理策略。
- prod 设置预算告警但不自动停机。
- 生成月度成本报告。
- 对公网 IP、NAT Gateway、大规格实例、GPU 做重点规则。

## 第七步：设计交付流程

推荐流程：

```text
需求 -> 修改 blueprint -> PR -> schema validate -> policy check -> generate docs -> generate IaC -> plan -> 人工审批 -> apply -> 生成变更报告
```

## 第八步：设计项目演示

个人项目建议做 3 个 demo：

1. **Startup Demo**：三云各一个 dev/prod 环境。
2. **Enterprise Demo**：安全、网络、共享服务、工作负载分层。
3. **Risk Demo**：故意缺少日志、标签、公网限制，让工具发现问题。

## 经典坑

| 坑 | 后果 | 标准解法 |
|---|---|---|
| 所有资源放一个账号 | 权限和风险混乱 | 多账号/多订阅/多项目隔离 |
| 生产和测试共用 VPC | 测试故障影响生产 | 环境级网络隔离 |
| 用 AK/SK 跑 CI | 密钥泄露风险 | OIDC/WIF 短期凭证 |
| 没有统一标签 | 成本无法归属 | 标签策略 + CI 检查 |
| 日志在各账号本地 | 审计困难 | 集中日志账号/项目/订阅 |
| 策略只写文档 | 无法执行 | Policy as Code |
| 直接手动改云资源 | IaC 漂移 | drift 检测 + 变更流程 |
