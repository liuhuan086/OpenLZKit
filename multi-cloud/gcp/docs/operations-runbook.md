# Google Cloud Operations Runbook

## 日常操作原则

GCP Landing Zone 运维围绕 folder/project lifecycle、IAM/WIF、Shared VPC、Org Policy 和日志导出。所有生产变更必须从 Terraform PR 进入；Console 操作只用于只读排障或已批准的 break-glass，事后必须 import 或回滚。

## 新项目接入

1. 确认 owner、billing account、folder、env、data classification 和网络域。
2. 在 `live/10-org` 或 `project-factory` 添加 project，默认 labels 完整。
3. 在 `live/20-identity` 添加 group/project IAM 或 service account。
4. 在 `live/30-network` / `35-connectivity` 接入 Shared VPC 或独立 VPC。
5. 在 `live/40-security` 确认继承 Org Policy；必要例外写明到期时间。
6. 在 `live/50-logging` 确认 audit logs sink 到日志 project。

## 权限变更

- 人员权限改 Cloud Identity group，不给个人长期绑定高权限。
- CI/CD 用 WIF + service account impersonation。
- 禁止下载 service account key；发现 key 立即禁用、轮换和复盘。

## 网络变更

- 先检查 CIDR、Shared VPC host/service 关系和子网 IAM。
- 生产和 sandbox 不共用 host project。
- 改动 firewall/route/NAT 前保留旧规则回滚路径。

## Drift 处理

```bash
terraform -chdir=multi-cloud/gcp/live/<stack> plan -detailed-exitcode
```

- 对手工新增资源，优先判断是否应纳管；纳管用 import 后补变量。
- 对手工删除资源，先评估是否有业务影响，再通过 Terraform 恢复或删除 state。

## 常见故障

| 场景 | 处理 |
|---|---|
| Project 创建失败 | 查 Resource Manager audit log、billing 权限、org policy 和 project id。 |
| WIF 失败 | 校验 provider attribute mapping、principalSet、repo subject。 |
| Shared VPC 不能用 | 检查 service project association、subnet IAM、Compute API。 |
| Org Policy 阻断上线 | 查具体 constraint，优先 folder 级临时例外并补偿控制。 |
| 日志 sink 不投递 | 检查 sink writer identity 对目标 bucket/BigQuery/PubSub 的权限。 |

## 变更验收

- Terraform fmt/validate、TFLint、Checkov、Conftest 通过。
- 关键输出可用：project id/number、folder id、service account email、network/subnet id。
- Audit logs 和 SCC finding 路径在 sandbox 中验证。
