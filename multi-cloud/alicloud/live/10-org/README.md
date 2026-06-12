# live/10-org (Alibaba Cloud)

Organization layer: builds the Resource Directory folder hierarchy via the
[`org`](../../modules/org) module. This is the first deployable stack after
`00-bootstrap`.

## State

Remote state in OSS (provisioned by `00-bootstrap`). Backend values are supplied
at init time and never committed:

```bash
cp backend.hcl.example backend.hcl   # fill in the bucket from 00-bootstrap
terraform init -backend-config=backend.hcl
```

## Workflow

```bash
terraform validate            # static, no account
terraform plan                # requires RD permissions on the management account
# apply runs only after PR review + environment approval (see docs/design/04)
```

## Preconditions

- `00-bootstrap` has enabled the Resource Directory and created the OSS state bucket.
- The caller uses management-account RAM credentials (prefer short-lived STS).
