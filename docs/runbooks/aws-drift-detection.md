# AWS Drift Detection

## 目标

发现手工变更、控制面异步收敛失败或外部系统修改导致的 IaC 漂移。

## 周期

- sandbox：每周至少一次。
- production：按变更窗口执行，或关键控制变更后执行。
- 账号售卖、SCP、日志和网络 stack：每次 apply 后执行。

## 检查

```bash
terraform -chdir=multi-cloud/aws/live/40-security plan -detailed-exitcode
```

退出码含义：

- `0`：无 drift。
- `1`：plan 失败，先排查凭证、provider、state lock。
- `2`：存在 drift，需要 review。

## 处置

| Drift 类型 | 处置 |
|---|---|
| 手工新增资源 | 评估是否 import；否则删除并复盘流程 |
| 手工修改 policy | 回滚到 Git 中声明的 policy 或提交 PR |
| AWS 控制面默认值变化 | 更新 module 文档和验收条件 |
| 外部系统管理资源 | 明确 ownership，避免双写 |
| state 损坏或 lock 残留 | 见 [terraform-state-recovery](terraform-state-recovery.md) |
