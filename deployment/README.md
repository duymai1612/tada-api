# QUICK OVERVIEW

- The common folder will store terraform config of common service, included.

- We separate terraform config into three environment: develop, staging, production.
- Every single environment include features:

* Deploy AWS Code build

# HOW TO USE TERRAFORM TO DEPLOY INFRASTRUCTURE TO AWS CLOUD

1. Install terraform CLI. After completed install terraform CLI, verify by type `terraform --version` to make sure it's works.

- From AWS Dashboard go to `IAM` to create user with suitable `roles` (it's better if full-access roles), get `aws_access_key_id` and `aws_secret_access_key` after created.

- Create `~/.aws/credentials` with template
  ````
  [default]
  aws_access_key_id=<created_aws_access_key_id>
  aws_secret_access_key=<created_aws_secret_access_key>
  ```
  ````

4. Deployment

- Go inside environment folder, for example `develop`
- Enter `terraform init`
- Enter `terraform apply` to deploy infrastructure.
