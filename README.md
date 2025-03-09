# Pairings API

## API Documentation

View the interactive API documentation:

[![API Documentation](https://img.shields.io/badge/API-Documentation-blue)](https://petstore.swagger.io/?url=https://raw.githubusercontent.com/marcusal/pairings-app/main/pairings-api/swagger/v1/swagger.yaml)

## Before running the application locally:

1. Copy the example prompts file:

```bash
cp config/prompts.example.yml config/prompts.yml
```

2. Update `config/prompts.yml` with your actual prompts and configuration

## Rails Local Development

Cd into the Rails project and run the usual commands:

```bash
bin/rails db:prepare
bin/rails db:seed
bin/rails s
bin/sidekiq
```

## Docker test production app locally

Cd into Rails project and run one of the following commands:

### Option 1: Use environment variable

```
export AWS_ACCOUNT_ID={YOUR_AWS_ACCOUNT_ID}
./bin/start-local
```

### Option 2: Let the script prompt you

```
./bin/start-local
# It will ask for your AWS Account ID
```

### Option 3: Start with temporary environment variable

```
AWS_ACCOUNT_ID={YOUR_AWS_ACCOUNT_ID} ./bin/start-local
```

## Terraform Development Workflow

This project uses LocalStack for local development and Terraform Cloud for production deployment.

### Setup

1. Install required tools:

   ```bash
   brew install localstack
   brew install terraform
   pip install terraform-local
   ```

2. Start LocalStack:
   ```bash
   localstack start
   ```

### Development Flow

#### Local Development (with LocalStack)

Use `tflocal` commands for local development. This will interact with LocalStack instead of real AWS services

#### Production Deployment (with Terraform Cloud)

When ready to deploy to real AWS infrastructure:

1. Copy the cloud configuration:

   Add to main.tf

   ```
      cloud {
         organization = "marcusal-dev"
         workspaces {
            name = "pairings-app"
         }
      }
   ```

2. Remove any state files:

   ```bash
   rm -rf .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
   ```

   ```bash
   terraform state rm $(terraform state list)
   ```

   Change backend security group to allow SSH access from your IP

3. Initialize and apply with regular Terraform commands:

   ```bash
   cd terraform-setup
   terraform init
   terraform plan \
   -var="db_username=someusername" \
   -var="db_password=somepassword" \
   -var="rails_master_key=$(cat ../pairings-api/config/master.key)" \
   -var="ecr_image_url=${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/{YOUR_IMAGE_NAME}" \
   -var="ssh_public_key=$(cat ~/.ssh/aws-deployer.pub)" \
   -var="environment=pairings-api-production" \
   -var="aws_account_id=$AWS_ACCOUNT_ID"

   terraform apply \
   -var="db_username=someusername" \
   -var="db_password=somepassword" \
   -var="rails_master_key=$(cat ../pairings-api/config/master.key)" \
   -var="ecr_image_url=${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/{YOUR_IMAGE_NAME}" \
   -var="ssh_public_key=$(cat ~/.ssh/aws-deployer.pub)" \
   -var="environment=pairings-api-production" \
   -var="aws_account_id=$AWS_ACCOUNT_ID"
   ```

4. After deployment, revert any changes to continue local development:
   ```bash
   git clean -f
   ```

### File Structure

- `main.tf` - Main Terraform configuration
- `outputs.tf` - Outputs for the Terraform configuration
- `variables.tf` - Variables for the Terraform configuration
- `terraform-setup` - Terraform configuration for the project
- `pairings-api` - Rails project

- `.gitignore` - Excludes local Terraform files and state

### Important Notes

- Never commit AWS credentials to the repository
- Use `terraform workspace show` to verify your current workspace

### TBA

- Seperate config for staging and production

## License

This project is proprietary software. See [LICENSE.md](LICENSE.md) for details.

All rights reserved. Any use, modification, or distribution of this software requires explicit written permission.

## Usage

To request access or inquire about licensing, please contact:

- Email: marcusgrantee@gmail.com

## Copyright

© 2025 mark allen. All rights reserved.
