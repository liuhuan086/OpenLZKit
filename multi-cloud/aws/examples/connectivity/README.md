# AWS Connectivity Example

This example validates the Transit Gateway hub-spoke contract with placeholder
VPC, subnet and account ids. It demonstrates route table isolation: shared,
prod, nonprod and sandbox are explicit network zones, and sandbox does not
propagate into prod.

Do not run `apply` from this example. Use `live/35-connectivity` in a sandbox
network account with real VPC/subnet ids and reviewed RAM share principals.
