# AWS Rollback

## 原则

- 先 rollback 变更范围最小的 leaf stack，再处理共享依赖。
- 不自动删除审计归档、state backend、Object Lock bucket 或生产日志。
- SCP/Tag Policy 先 detach 后 delete。
- 账号创建、Identity Center、Security Hub、GuardDuty、Config delegated admin 可能存在异步状态，必须等待 AWS 控制面收敛。

## 常见回滚路径

| 变更 | 首选回滚 | 注意事项 |
|---|---|---|
| SCP 误拦截 | 从 sandbox OU detach policy | 确认 break-glass role 未被拦截 |
| Tag Policy 误报 | detach 或放宽 sandbox scope | 不要直接从 root 删除生产策略 |
| IAM trust 错误 | 回滚 trust policy 到上一版 | 用 Conftest 重新验证无 wildcard principal |
| TGW 路由错误 | 移除 propagation/association | 先确认不会切断审计或 shared services |
| Config/Security Hub delegated admin 错误 | deregister delegated admin | 部分服务需要在 delegated account 先关闭 |
| Budget/CUR 错误 | 删除测试 budget/CUR | 不影响生产账单导出 |
| Workload handoff 错误 | 删除 workload role/output | 通知业务团队停止使用旧 handoff |

## 验证

1. `terraform plan -detailed-exitcode` 返回无预期外 drift。
2. CloudTrail 可看到回滚操作。
3. Config/Security Hub 没有新增高危 finding。
4. 受影响团队确认访问、网络或预算恢复。
