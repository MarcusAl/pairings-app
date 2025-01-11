## Terraform Development Workflow

This project uses LocalStack for local development and Terraform Cloud for production deployments.

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

Use `tflocal` commands for local development. This will interact with LocalStack instead of real AWS services:

#### Production Deployment (with Terraform Cloud)

When ready to deploy to real AWS infrastructure:

1. Copy the cloud configuration:

   ```bash
   cp main.tf.cloud main.tf
   ```

2. Initialize and apply with regular Terraform commands:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. After deployment, revert to local configuration:
   ```bash
   git checkout main.tf
   ```

### File Structure

- `main.tf` - Main Terraform configuration (local development version)
- `main.tf.cloud` - Production configuration with Terraform Cloud settings
- `.gitignore` - Excludes local Terraform files and state

### Important Notes

- Join workspace and login to Terraform Cloud before deploying
- Never commit AWS credentials to the repository
- Use `terraform workspace show` to verify your current workspace
