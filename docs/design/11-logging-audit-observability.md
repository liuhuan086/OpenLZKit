# 日志、审计与可观测性

## 目标

- 所有管理操作可追踪。
- 所有安全事件可告警。
- 所有关键日志集中保存。
- 日志账号/项目与业务账号/项目隔离。

## 日志类型

- 控制平面操作日志。
- 配置变更日志。
- 网络流日志。
- 安全告警日志。
- CI/CD 执行日志。
- Terraform plan/apply 记录。

## 集中日志架构

```text
Workload Accounts / Projects / Subscriptions
    -> Audit / Logging Pipeline
        -> Log Archive Account / Project / Subscription
            -> Long-term Storage
            -> SIEM / Security Analytics
            -> Alerting
```

## 基线要求

- 日志归档账号独立。
- 日志存储启用加密。
- 日志存储启用防删除或保留策略。
- 高危操作告警。
- CI/CD 变更记录与云审计记录可以关联。
- 日志保留周期按企业合规要求配置。
