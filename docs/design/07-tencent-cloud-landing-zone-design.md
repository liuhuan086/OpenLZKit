# 腾讯云 Landing Zone 设计说明

## 1. 定位

腾讯云是 OpenLZKit 的第三朵云。它的目标是补齐中国大陆多云场景，而不是在 MVP 阶段和阿里云、AWS 平均投入。

MVP 阶段腾讯云先完成：

- 蓝图 schema 支持。
- 目录结构支持。
- 账号、CAM、VPC、CCN、日志和预算的概念映射。
- 文档生成。
- 基础 IaC 模板占位。

---

## 2. 核心组成

| 能力域 | 腾讯云相关能力 | OpenLZKit 输出 |
|---|---|---|
| 组织与账号 | Tencent Cloud Organization、成员账号 | 账号矩阵、组织层级说明 |
| 身份与权限 | CAM、CAM 用户、用户组、角色、策略 | 角色矩阵、最小权限建议 |
| 网络 | VPC、子网、安全组、NAT、CCN | 网络矩阵、Hub-Spoke 对照设计 |
| 日志审计 | CloudAudit、CLS | 审计日志基线 |
| 监控 | Cloud Monitor | 告警基线 |
| 成本 | 标签、预算、费用中心能力 | 成本责任矩阵 |

---

## 3. 推荐账号结构

```text
management account
├── security
│   └── audit-log-account
├── infrastructure
│   └── connectivity-account
├── workloads
│   ├── prod-app-account
│   └── dev-app-account
└── sandbox
    └── sandbox-account
```

---

## 4. CAM 设计

腾讯云使用 CAM 做权限管理。OpenLZKit 中不要把 CAM 与 AWS IAM 或阿里云 RAM 强行等价，只能抽象为 `identity_provider` 和 `role_binding`。

推荐输出：

- CAM 用户组矩阵。
- CAM 角色矩阵。
- 成员账号访问路径说明。
- 机器身份权限边界说明。

---

## 5. 网络设计

腾讯云多 VPC、多地域互联可以用 CCN 做 Hub-Spoke 或全网互联设计。

OpenLZKit 只在 MVP 阶段输出设计和模板占位，不默认创建真实 CCN 资源。

---

## 6. 后置原因

腾讯云放在第三阶段，不是因为不重要，而是因为：

1. 先做阿里云更贴合你的简历和国内企业环境。
2. AWS 作为第二朵云更容易体现经典多账号治理能力。
3. 腾讯云可以在第三阶段用来证明项目真的具备 provider adapter 扩展能力。
