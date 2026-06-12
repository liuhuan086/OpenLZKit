# 运维手册

## 1. 新增一个云账号/订阅/项目

> 下面的 `openlzkit` CLI / `blueprint.yaml` 属于可选的 `tools/` 生成器层（规划中），
> 非核心 IaC。未启用生成器时，直接在 `multi-cloud/<cloud>/live/10-org` 等对应分层中编写
> Terraform/OpenTofu 并走相同的 PR → plan → 审批 → apply 流程即可。

启用生成器时的流程：

1. 在 `blueprint.yaml` 添加 resource container。
2. 指定 owner、env、cost_center、budget。
3. 指定网络段或关联已有网络。
4. 指定角色绑定。
5. 执行：

```bash
openlzkit validate blueprint.yaml
openlzkit render-docs blueprint.yaml --out docs/generated
openlzkit generate-iac blueprint.yaml --out multi-cloud/<cloud>/live
```

6. 提交 PR。
7. CI 通过后人工审核。
8. 在测试环境执行 plan。
9. 审批后 apply。

## 2. 新增一个角色

1. 在统一角色模型中定义 role。
2. 映射到 AWS/Azure/GCP 原生权限。
3. 增加策略校验。
4. 更新 role-matrix。
5. 测试最小权限。

## 3. 新增一个策略

1. 在 `multi-cloud/<cloud>/policies/` 中添加规则（如 Rego）。
2. 在 `multi-cloud/<cloud>/tests/` 添加正反用例。
3. 在文档中说明规则含义。
4. 在该云 `policies/` 的配置中设置默认级别。

## 4. 处理策略失败

优先级：

1. 如果是 Critical，默认阻断。
2. 如果是 High，必须修复或提供例外。
3. 如果是 Medium，可以进入 backlog，但要有 owner。
4. 如果是 Low，记录建议。

## 5. 处理 IaC Drift

如果发现实际云资源和 IaC 不一致：

1. 判断变更是否为紧急人工操作。
2. 如果是合理变更，导入或更新 IaC。
3. 如果是不合理变更，回滚资源。
4. 增加策略防止复发。
5. 记录复盘。

## 6. 生产事故时的 Break-glass 流程

1. 触发事故工单。
2. 两人确认启用 break-glass。
3. 使用 MFA 登录。
4. 所有操作记录到审计日志。
5. 事故结束后立即回收权限。
6. 输出复盘报告。
