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

3. Initialize and apply with regular Terraform commands:

   ```bash
   terraform init
   terraform plan

   (confirm changes)

   terraform apply
   ```

4. After deployment, revert any changes to continue local development:
   ```bash
   git clean -f
   ```

### File Structure

- `main.tf` - Main Terraform configuration (local development version)

- `.gitignore` - Excludes local Terraform files and state

### Important Notes

- Join workspace and login to Terraform Cloud before deploying
- Never commit AWS credentials to the repository
- Use `terraform workspace show` to verify your current workspace
