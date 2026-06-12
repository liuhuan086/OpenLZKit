# 多云策略

## 多云目标

OpenLZKit 的多云不是“跨云无差别部署同一套资源”，而是：

1. 学习并展示五朵云的企业治理能力。
2. 沉淀统一的工程标准。
3. 保留每朵云的原生架构。
4. 对比各云在组织、身份、网络、安全、日志、成本方面的异同。

## 多云目录策略

顶层使用：

```text
multi-cloud/
├── alicloud/
├── aws/
├── tencentcloud/
├── azure/
└── gcp/
```

每个云目录内部独立维护 modules、live、docs、policies、examples、tests。

## 不做的事情

- 不做单一 `multi_cloud_account` 抽象模块。
- 不把 AWS SCP 强行映射为 Azure Policy。
- 不把 GCP Folder 强行解释为 AWS OU。
- 不把所有云放进一个 Terraform state。
- 不用一个超级 CI Job 同时 apply 五朵云。

## 做的事情

- 统一命名规范。
- 统一标签规范。
- 统一测试门禁。
- 统一 PR 流程。
- 统一模块 README 模板。
- 统一交付物清单。
- 统一安全评审标准。

## 推荐优先级

1. 阿里云：贴近国内企业场景。
2. AWS：全球企业标准、简历识别度高。
3. Azure：企业身份、管理组和策略体系成熟。
4. GCP：项目/文件夹/Shared VPC/组织策略清晰。
5. 腾讯云：补齐国内多云能力，适合作为差异化亮点。
