# Landing Zone 常见问题与标准解决方案

## 1. 多账号到底按什么拆

### 问题

很多团队不知道按业务、环境、团队还是成本中心拆账号。

### 建议

优先级：

1. 安全边界
2. 环境边界
3. 团队/业务边界
4. 成本边界

生产、测试、开发、沙箱尽量分开。安全、日志、网络、共享服务建议独立。

## 2. 管理组/OU 是否要完全照组织架构

不建议。

组织架构经常变，云资源层级应该围绕策略、合规和隔离来设计。组织架构可以通过标签、成本中心、owner 字段表达。

## 3. 为什么不把所有权限放到一个超级管理员

因为超级管理员方便但不可控：

- 容易误操作。
- 难审计。
- 离职交接风险大。
- 不符合最小权限。

标准解法：角色拆分 + JIT/PIM + break-glass。

## 4. 多云是不是一定要完全统一

不应该强行 1:1 统一。

正确方式是：

- 统一治理模型。
- 保留云厂商原生差异。
- 用 adapter 做映射。

例如 AWS Account、Azure Subscription、GCP Project 都可以抽象成 ResourceContainer，但底层生命周期、权限和限制不同。

## 5. Landing Zone 和 Kubernetes 平台是什么关系

Landing Zone 是云基础地基，Kubernetes 平台是运行时平台。

顺序通常是：

```text
Landing Zone -> Network/Security/Identity -> Kubernetes Cluster -> App Platform -> Workloads
```

如果没有 Landing Zone，K8s 集群会缺少统一网络、日志、安全、成本和账号边界。

## 6. 如何低成本做个人项目

不要一开始真实创建大量云资源。

推荐：

- 使用 YAML 蓝图建模。
- 生成 IaC 模板但默认不 apply。
- 用 mock blueprint 演示企业结构。
- 用 policy 检查体现治理能力。
- 用报告输出体现架构能力。

## 7. 如何产生收益

可能路径：

1. 开源项目积累 Star，作为求职背书。
2. 写文章/视频/课程，讲多云 Landing Zone 设计。
3. 提供中小企业云账号治理咨询。
4. 做 SaaS 化版本：上传 blueprint，生成报告和风险评分。
5. 做企业内部平台插件：账号申请、权限申请、策略检查。

最现实的第一收益不是直接卖软件，而是提升求职和接私活可信度。

## 8. 项目过大怎么办

用 MVP 切：

- 第一阶段只做 AWS。
- 第二阶段加 Azure/GCP 模型。
- 第三阶段加 IaC 生成。
- 第四阶段加策略。
- 第五阶段加 UI。

不要一开始做完整企业平台。

## 9. Terraform state 容易互相影响

按云、阶段（`00-bootstrap` … `70-workload-onboarding`）、环境拆分 state；后端启用加密和锁；生产 apply 单独审批；禁止本地 state 进入仓库。

## 10. 公司已有存量账号怎么纳管

先盘点账号、权限、网络、日志、账单，再设计目标结构。新业务走新 Landing Zone，存量业务分阶段纳管，不建议一刀切迁移。

## 11. 安全规则影响业务上线怎么办

Guardrails 分级：阻断 / 告警 / 建议。对 Sandbox 宽松，对 Prod 严格。提供例外申请流程，并带 reason、owner、expiry_date 和补偿控制（参见 [03-security-governance-design](../design/03-security-governance-design.md) 的例外机制）。

## 12. 成本标签没人填怎么办

Terraform module 强制标签输入；Policy 阻止缺标签资源；默认标签在 provider/module 层合并；成本报表按标签输出。

## 13. 多团队不知道怎么接入

提供 workload onboarding 模板、账号申请表、权限申请表、网络接入清单和上线前检查表。

## 14. 云厂商服务名不同，文档难维护

统一使用共同能力域：org、identity、network、security、logging、finops；在每朵云目录下写原生实现；用 [references.md](../references.md) 维护官方文档链接。
