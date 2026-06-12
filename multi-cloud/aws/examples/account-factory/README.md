# AWS Account Factory Example

This example validates the account vending contract without using real account
ids or emails. It is intentionally separate from `examples/basic` because
`aws_organizations_account` creates real AWS accounts during apply.

Do not run `apply` from this example. Use `live/10-org` with reviewed account
requests and short-lived credentials from a sandbox management account.
