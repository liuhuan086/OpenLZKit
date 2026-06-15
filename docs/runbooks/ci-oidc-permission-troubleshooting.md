# CI OIDC Permission Troubleshooting

## 症状

- CI 无法 AssumeRole。
- Terraform init/plan 报 `AccessDenied`。
- Conftest 通过但 AWS API 调用失败。
- trust policy 更新后 GitHub Actions 或其他 CI provider 失效。

## 排查顺序

1. 检查 OIDC provider issuer、audience 和 thumbprint 是否匹配。
2. 检查 role trust policy 是否限制正确的 repo、branch、environment 或 subject。
3. 检查 permission policy 是否覆盖目标 stack 所需 API。
4. 检查 SCP 是否拦截 CI role。
5. 检查 session name、external id、region 和 provider alias。
6. 用最小 read-only AWS CLI 调用验证凭证。

## Policy-as-Code

- `multi-cloud/aws/policies/iam_trust.rego` 应阻止 wildcard principal。
- `multi-cloud/aws/policies/iam_policy.rego` 应阻止非边界策略中的 `Action="*"` + `Resource="*"`。
- 修复 trust 或 policy 后先运行 Rego unit tests，再跑 plan。

## 修复后证据

- CI job id 和时间窗口。
- AssumeRole 成功摘要。
- plan 或 validate 成功摘要。
- CloudTrail 中 `AssumeRoleWithWebIdentity` 的脱敏事件摘要。
