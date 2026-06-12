# FinOps 与成本治理

## 目标

- 资源成本可归因。
- 异常成本可告警。
- 闲置资源可发现。
- 预算和业务线绑定。

## 标签规范

必填标签：

| 标签 | 示例 | 说明 |
|---|---|---|
| `owner` | `platform-team` | 资源负责人 |
| `cost_center` | `cc-001` | 成本中心 |
| `env` | `dev/staging/prod` | 环境 |
| `project` | `payment` | 项目 |
| `managed_by` | `terraform` | 管理方式 |
| `data_classification` | `public/internal/confidential` | 数据等级 |

## 成本控制策略

- Sandbox 默认预算上限。
- Dev 环境非工作时间可关闭。
- 大规格资源需要审批。
- GPU、NAT、日志、快照、对象存储生命周期重点监控。
- 每月输出成本报告。

## 商业化方向

- 提供 Landing Zone 成本评估模板。
- 提供闲置资源检查清单。
- 提供企业 FinOps 标签治理实施包。
- 提供多云成本治理咨询。
