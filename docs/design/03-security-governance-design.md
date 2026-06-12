# 安全治理与策略设计

## 1. 治理层级

```text
组织级策略
├── 身份策略
├── 网络策略
├── 日志策略
├── 加密策略
├── 标签策略
├── 成本策略
└── 例外策略
```

## 2. 基础安全基线

| 控制项 | 要求 |
|---|---|
| 审计日志 | 所有生产环境集中采集 |
| 配置记录 | 记录关键资源配置变化 |
| MFA | 高权限用户强制 MFA |
| 加密 | 生产数据默认加密 |
| 公网访问 | 默认拒绝，例外必须说明 |
| 标签 | owner/env/cost_center 必填 |
| root/owner | 不用于日常操作 |
| 密钥 | 不允许长期密钥作为默认 CI/CD 认证 |

## 3. 策略分类

### Preventive

预防型策略，例如禁止创建公网存储桶。

### Detective

检测型策略，例如发现未打标签资源。

### Corrective

纠正型策略，例如自动添加默认标签或自动关闭临时资源。

## 4. Policy as Code

策略应该放在仓库里，通过 CI 执行。

优先级：

1. schema 校验：字段是否正确。
2. blueprint 策略：设计是否符合组织规范。
3. IaC 静态扫描：生成的代码是否危险。
4. plan 策略：将要创建的资源是否违规。

## 5. 例外机制

真实企业一定有例外。例如某个公开网站必须有公网入口。

例外必须包含：

- reason
- owner
- expiry_date
- approval_ticket
- compensating_controls

示例：

```yaml
exceptions:
  - id: ex-public-api-001
    rule: no_public_ingress
    resource: app-prod-api
    reason: public customer API
    owner: platform-team
    expiry_date: 2026-12-31
    compensating_controls:
      - waf
      - rate_limit
      - tls
```

## 6. 风险报告格式

```text
Risk ID: RISK-001
Title: Production account has no centralized audit log
Severity: High
Affected: aws/app-prod
Why it matters: Incident response and compliance audit will be difficult.
Fix: Enable CloudTrail organization trail and send logs to log archive account.
```
