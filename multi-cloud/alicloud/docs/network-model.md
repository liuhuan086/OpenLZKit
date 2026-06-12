# Alibaba Cloud Network Model

## 1. 解决的企业问题

企业多账号环境需要把共享服务、生产、非生产和 sandbox 网络连接起来，同时避免
sandbox 与生产互通、避免所有 VPC 自动全互通。阿里云网络模型分为两层：

- 账号内网络基线：VPC、vSwitch、默认拒绝安全组。
- 跨账号连接基线：CEN + Transit Router + 路由表隔离 + 显式路由。

## 2. 使用的云原生服务

- **VPC / vSwitch / Security Group**：账号内网络边界。
- **CEN**：企业网络骨干。
- **Transit Router**：Hub-Spoke 连接与路由中心。
- **Transit Router route table**：按环境/安全域隔离路由。
- **Transit Router VPC attachment**：连接 VPC 到 Hub。
- **Transit Router grant attachment**：跨账号授权网络实例接入 CEN。

## 3. Terraform 模块边界

由 [`modules/network`](../modules/network) 实现：

- **负责**：单账号 VPC、vSwitch、默认拒绝安全组。
- **不负责**：CEN、Transit Router、跨账号连接、全局路由。

由 [`modules/connectivity`](../modules/connectivity) 实现：

- **负责**：CEN、Transit Router、路由表、VPC attachment、跨账号 grant、association、propagation、显式 route entry。
- **不负责**：创建工作负载 VPC、应用安全组规则、DNS/防火墙策略。

## 4. 推荐拓扑

```text
network account
└── CEN / Transit Router
    ├── shared route table  <-> shared-services VPC
    ├── prod route table    <-> prod workload VPCs
    ├── nonprod route table <-> dev/staging workload VPCs
    └── sandbox route table <-> sandbox VPCs
```

原则：

- `prod` 可显式访问 `shared`。
- `sandbox` 默认不传播到 `prod`。
- 敏感网络段优先使用显式 route entry。
- 跨账号 attachment 必须有对应 grant。

## 5. 输入、输出与依赖

- `modules/network` 输入：`name`、`cidr_block`、`vswitches`、`tags`。
- `modules/network` 输出：`vpc_id`、`vswitch_ids`、`security_group_id`。
- `modules/connectivity` 输入：`route_tables`、`vpc_attachments`、`grant_attachments`、`route_entries`。
- `modules/connectivity` 输出：`cen_id`、`transit_router_id`、`route_table_ids`、`vpc_attachment_ids`。
- 依赖：VPC/vSwitch 已存在；跨账号 VPC 已授权；调用方具备 CEN/TR 权限。

## 6. 测试

静态检查（无需云账号）：`fmt` + `init -backend=false` + `validate`，见
[../tests/README.md](../tests/README.md)。`plan` 需 sandbox network account。

## 7. 回滚

- 先删除 route entry。
- 删除 route table propagation / association。
- 删除 VPC attachment 与 grant。
- 最后删除 Transit Router route table、Transit Router、CEN。

## 8. 常见故障排查

| 现象 | 可能原因 | 处理 |
|---|---|---|
| VPC attachment 失败 | vSwitch zone mapping 不完整 | 为每个 attachment 提供可用区与 vSwitch |
| 跨账号 attachment 失败 | 缺少 grant 或 owner id 错误 | 使用目标账号 id 配置 `grant_attachments` |
| sandbox 能访问 prod | route table propagation 过宽 | 将 sandbox 放入独立 route table，移除 prod propagation |
| 路由不生效 | association/propagation 缺失 | 检查 attachment 是否关联和传播到目标 route table |
