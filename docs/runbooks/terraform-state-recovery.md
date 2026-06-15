# Terraform State Recovery

## 原则

- state 是生产资产，恢复前先备份。
- 不在本地或仓库保存未加密 state。
- 不用 `terraform state rm` 或 import 覆盖问题，除非 PR/变更单说明原因、影响和回滚。

## 场景

| 场景 | 处理 |
|---|---|
| State lock 残留 | 确认没有运行中的 apply，再解除 lock |
| State bucket policy 错误 | 使用 break-glass 修复最小访问 |
| State 版本损坏 | 从版本化 bucket 恢复上一版本 |
| 资源已存在但 state 缺失 | 用 `terraform import`，并提交 import 说明 |
| 需要迁移 state 地址 | 先写迁移说明或 ADR，再用 `moved` block 或受控 state mv |

## 恢复后验证

1. `terraform init` 成功。
2. `terraform plan -detailed-exitcode` 不包含预期外替换。
3. state backend 仍有加密、版本化、public access block 和 lock。
4. 恢复过程有 CloudTrail 或等价审计记录。
