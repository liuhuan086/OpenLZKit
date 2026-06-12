# 阿里云 Landing Zone 设计说明

## 1. 定位

阿里云是 OpenLZKit 的第一朵云。MVP 阶段应优先把阿里云做深，而不是一开始平均支持所有云厂商。

目标不是替代阿里云官方企业多账号治理能力，而是提供一套开源、可学习、可演示、可生成文档和 IaC 的 Landing Zone 脚手架。

---

## 2. 核心组成

| 能力域 | 阿里云相关能力 | OpenLZKit 输出 |
|---|---|---|
| 组织与账号 | Resource Directory、成员账号、资源夹 | 账号矩阵、资源夹规划、账号职责说明 |
| 身份与权限 | RAM 用户、RAM 用户组、RAM 角色、策略 | 角色矩阵、最小权限建议、跨账号访问说明 |
| 网络 | VPC、交换机、安全组、NAT、CEN/Transit Router | 网络矩阵、CIDR 规划、Hub-Spoke 说明 |
| 日志审计 | ActionTrail、SLS | 审计日志基线、集中日志方案 |
| 监控 | CloudMonitor | 告警基线、监控责任边界 |
| 成本 | 标签、预算、费用中心能力 | 成本标签规则、预算阈值、成本责任矩阵 |
| 安全 | 安全组、RAM 策略、日志、加密、基线检查 | 风险报告、策略校验结果 |

---

## 3. 推荐账号结构

```text
management account
├── security
│   ├── audit-log-account
│   └── security-tooling-account
├── infrastructure
│   ├── network-account
│   └── shared-services-account
├── workloads
│   ├── prod-app-account
│   └── dev-app-account
└── sandbox
    └── sandbox-account
```

设计原则：

1. 管理账号不承载业务资源。
2. 审计日志账号独立。
3. 网络账号独立。
4. 生产和非生产账号分离。
5. sandbox 必须有限额和预算告警。

---

## 4. RAM 设计

建议把人员身份和机器身份分开。

### 人员身份

| 组 | 职责 | 权限建议 |
|---|---|---|
| platform-team | 平台和网络基础设施 | 管理网络、IaC、共享服务 |
| security-team | 安全审计 | 只读审计、日志、策略查看 |
| app-team | 业务应用 | 仅访问所属业务账号和环境 |
| finops-team | 成本治理 | 费用、标签、预算只读或管理 |

### 机器身份

| 身份 | 用途 | 原则 |
|---|---|---|
| github-actions-plan | CI plan / validate | 只读 + plan 所需权限 |
| github-actions-apply-dev | dev apply | 仅 dev 环境，需审批 |
| github-actions-apply-prod | prod apply | 强审批，最小权限，禁止长期 AK |

---

## 5. 网络设计

推荐 Hub-Spoke：

```text
shared/network account
  └── hub vpc / cen / transit router
        ├── dev vpc
        ├── prod vpc
        └── shared-services vpc
```

关键原则：

- CIDR 统一规划，禁止重叠。
- dev、prod、sandbox 默认不互通。
- prod 到 shared 走私网互联。
- sandbox 到 prod 默认拒绝。
- 出口流量统一审计。

---

## 6. OpenLZKit 阿里云 MVP 输出物

- `alicloud-account-matrix.md`
- `alicloud-role-matrix.md`
- `alicloud-network-matrix.md`
- `alicloud-security-baseline.md`
- `alicloud-risk-report.md`
- `multi-cloud/alicloud/modules/*`
- `multi-cloud/alicloud/live/<NN-layer>/*`（`00-bootstrap` … `70-workload-onboarding`）

---

## 7. 面试讲法

可以这样描述：

> 我把阿里云作为 OpenLZKit 的第一朵云来做，是因为国内企业多云场景里阿里云更常见。我没有只写 Terraform 脚本，而是先设计了账号分层、资源目录、RAM 权限矩阵、网络 Hub-Spoke、日志审计、成本标签和策略校验，然后用 blueprint 驱动 IaC 和文档生成。这样项目既能体现云架构能力，也能体现平台工程和 DevSecOps 思维。
