# 身份与访问设计

## 1. 目标

建立一套跨 AWS、Azure、GCP 的统一身份访问模型，使人类用户和机器身份都能被标准化管理。

## 2. 设计原则

- 人和机器身份分离。
- 默认只读，按需授权。
- 生产权限必须审批、限时、可审计。
- CI/CD 使用短期凭证，不保存长期密钥。
- 权限以角色为中心，不以个人为中心。
- 先定义统一角色，再映射到云厂商权限。

## 3. 角色层级

```text
Organization Roles
├── platform-admin
├── security-auditor
├── network-admin
├── app-admin
├── app-developer
├── cicd-planner
├── cicd-deployer
├── finance-viewer
└── break-glass-admin
```

## 4. 机器身份设计

### CI/CD 身份

CI/CD 不应该使用人类账号，也不应该默认使用长期 AK/SK。

推荐：

- GitHub Actions -> OIDC -> Cloud Role
- GitLab CI -> OIDC/JWT -> Cloud Role
- HCP Terraform -> OIDC -> Cloud Role

### 权限拆分

- plan 角色：只读 + 读取 state + 生成 plan。
- apply 角色：可变更资源，但只在受保护环境执行。
- security scan 角色：读取配置和 plan，不写资源。

## 5. Break-glass 设计

Break-glass 账号用于紧急情况，不用于日常维护。

要求：

- 至少两人持有。
- MFA 强制。
- 使用即告警。
- 使用后复盘。
- 权限定期验证。

## 6. OpenLZKit 中的身份建模

```yaml
identity:
  source: entra-id
  groups:
    - name: platform-team
      roles:
        - platform-admin
    - name: security-team
      roles:
        - security-auditor
  machine_identities:
    - name: github-actions-main
      auth: oidc
      allowed_repositories:
        - org/openlzkit
      roles:
        - cicd-planner
        - cicd-deployer
```

## 7. 验收规则

- 每个 prod scope 至少有 auditor。
- 每个 deployer 必须声明 auth 类型。
- machine identity 不允许配置 password、access_key、client_secret 作为默认方式。
- break-glass 必须开启 MFA 和 alert。
