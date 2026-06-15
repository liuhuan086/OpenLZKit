# OpenLZKit 测试用例

| ID | 类别 | 云 | 目标 | 前置条件 | 步骤 | 期望结果 | 风险 |
|---|---|---|---|---|---|---|---|
| TC-001 | 格式 | 全部 | Terraform 代码 | 已检出仓库 | 运行 `terraform fmt -check -recursive` | 无格式 diff | 低 |
| TC-002 | 语法验证 | 全部 | 每个 module、example 和 live stack | provider init 可用 | 对每个 Terraform 目录运行 `terraform init -backend=false && terraform validate` | validate 成功 | 中 |
| TC-003 | Lint | 全部 | HCL | 已安装 TFLint | 运行 `tflint --recursive` | 无关键 lint 错误 | 中 |
| TC-004 | 安全扫描 | 全部 | HCL | 已安装 Checkov/tfsec | 运行安全扫描 | 无高危问题 | 高 |
| TC-005 | 策略测试 | 全部 | Plan JSON | 已安装 OPA/Conftest | 运行自定义策略 | 必填标签、加密、禁止公网高危入口等规则生效 | 高 |
| TC-006 | State | 全部 | live stack | backend 已配置 | 初始化远程 backend | State 远程存储且具备锁或等价保护 | 高 |
| TC-007 | 身份 | 全部 | CI/CD 角色 | sandbox 凭证可用 | 使用 CI 角色执行 plan | 只能 plan/apply 被授权 stack | 高 |
| TC-008 | 日志 | 全部 | 审计基线 | sandbox 环境 | 创建测试事件 | 事件进入集中日志 | 高 |
| TC-009 | 网络 | 全部 | 网络基线 | sandbox 环境 | 部署示例 VPC/VNet/network | 默认无公网高危入站 | 高 |
| TC-010 | FinOps | 全部 | 标签 | 示例资源 | 对缺少必填标签的资源执行 plan | 策略失败 | 中 |
| TC-011 | Drift | 全部 | live stack | 已部署资源 | 手工修改资源后运行 plan | 检测到 drift | 中 |
| TC-012 | 回滚 | 全部 | 模块发布 | 有上一版本可用 | 回退模块版本 | 回滚路径有文档说明 | 高 |
| TC-013 | 文档 | 全部 | Markdown 链接 | 已检出仓库 | 运行本地 Markdown 链接检查 | 内部链接有效；外部链接尽量指向官方或厂商文档 | 中 |
| TC-014 | 文档 | 全部 | 权威文档 | 文档有变更 | 扫描 `TODO`、`TBD` 和占位描述 | 权威文档无未解决占位内容 | 中 |
| TC-015 | 敏感信息 | 全部 | 代码和文档 | 已检出仓库 | 扫描疑似真实 secret、个人仓库、租户/账号 ID | 只出现 `example-org`、`123456789012` 等明显假值 | 高 |
| TC-016 | Static release | 全部 | 文档、Demo、request 样例 | 已检出仓库 | 运行 `python tools/static_release_gate.py` | Markdown 内链、TODO/TBD、敏感值形态、Demo 文件、request 必填字段和标签均通过 | 高 |
| TC-017 | 模块契约 | 全部 | module README 与 HCL | 模块有变更 | 对比 README 输入/输出与 `variables.tf`、`outputs.tf` | README 覆盖变量、输出、示例和安全注意事项 | 中 |
| TC-018 | 账号售卖 | AWS/阿里云/腾讯云/GCP/Azure | 账号/订阅/项目工厂 | sandbox 组织或租户 | 创建一个带必填标签/labels 的 sandbox 容器 | 容器进入预期 OU/folder/management group/node 并继承策略 | 高 |
| TC-019 | 护栏推广 | 全部 | 组织策略 | sandbox 组织或租户 | 只在 sandbox 附加 deny 策略并尝试违规操作 | sandbox 中操作被拒绝；生产不受影响 | 高 |
| TC-020 | 例外生命周期 | 全部 | 策略例外 | 例外流程已定义 | 创建带到期时间的测试例外并让其过期 | 例外可审计，并被移除或重新审批续期 | 高 |
| TC-021 | Break-glass | 全部 | 应急访问 | break-glass 已配置 | 执行受控登录演练 | MFA、告警、审计日志和使用后复盘均发生 | 严重 |
| TC-022 | OIDC/WIF | 全部 | CI/CD 联合身份 | GitHub 测试仓库或等价 CI 可用 | 不使用长期 secret 完成认证并执行只读 plan | 短期令牌可用；无需静态云 secret | 高 |
| TC-023 | 日志不可变 | 全部 | 日志归档 | sandbox logging stack | 尝试未授权删除或修改日志策略 | 删除/修改被拒绝或被审计；保留期仍有效 | 严重 |
| TC-024 | 网络隔离 | 全部 | prod/nonprod/sandbox 网络 | sandbox 网络已部署 | 测试跨域路由可达性 | sandbox 不可达 prod；共享服务只经批准路径可达 | 高 |
| TC-025 | 成本控制 | 全部 | 预算、标签、labels | sandbox 计费权限可用 | 创建未打标签或超预算测试资源 | CI/策略捕获缺失元数据；支持时预算告警触发 | 中 |
| TC-026 | State 迁移 | 全部 | 模块重构 | 已准备 moved/import plan | 资源地址迁移后运行 plan | 生产资源无非预期 destroy/create | 严重 |

## 测试说明

- 静态测试必须在没有生产云凭证的情况下可运行。
- Plan 和集成测试只在 sandbox 账号、订阅或项目中运行。
- 安全、state、日志或 break-glass 测试失败会阻塞生产发布。
- 如果本地因工具缺失无法运行某项测试，PR 必须说明缺口，并在 merge 前依赖 CI 或 sandbox 运行补齐验证。
