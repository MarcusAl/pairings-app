# Pairings API

## API Documentation

View the interactive API documentation:

[![API Documentation](https://img.shields.io/badge/API-Documentation-blue)](https://petstore.swagger.io/?url=https://raw.githubusercontent.com/marcusal/pairings-app/main/pairings-api/swagger/v1/swagger.yaml)

Before running the application locally:

1. Copy the example prompts file:

```bash
cp config/prompts.example.yml config/prompts.yml
```

2. Update `config/prompts.yml` with your actual prompts and configuration

## System dependencies

Install ruby 3.4.1 with your package manager (mise is recommended)

```
brew install postgresql@14
brew services start postgresql@14
brew install redis
brew services start redis
brew services list
```

## Create a postgres user with password

```
createuser -U postgres -d -R -S -P {{username}}
```

OR

```
sudo -u postgres psql

CREATE USER admin WITH PASSWORD 'your_password' CREATEDB;
\q
```

## Gems setup

```
gem install rails
gem install bundler
bundle install
```

## Env setup

Update .env.development with your own values

```
cp .env.example .env.development
```

## Create db

```
rails db:create
rails db:migrate
rails db:seed
```

## Start server and sidekiq

```
rails s
bundle exec sidekiq
```

## Docker

cd into Rails project and run

```
bin/deploy-local
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
   terraform plan -var="db_username=someusername" -var="db_password=somepassword" -var="rails_master_key=$(cat ../pairings-api/config/master.key)" -var="ecr_image_url=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/pairings-api:v1.0.0" -var="ssh_public_key=$(cat ~/.ssh/aws-deployer.pub)" -var="environment=production"

   (confirm changes)

   terraform apply -var="db_username=someusername" -var="db_password=somepassword" -var="rails_master_key=$(cat ../pairings-api/config/master.key)" -var="ecr_image_url=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/pairings-api:v1.0.0" -var="ssh_public_key=$(cat ~/.ssh/aws-deployer.pub)" -var="environment=production"
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

## License

This project is proprietary software. See [LICENSE.md](LICENSE.md) for details.

All rights reserved. Any use, modification, or distribution of this software requires explicit written permission.

## Usage

To request access or inquire about licensing, please contact:

- Email: marcusgrantee@gmail.com

## Copyright

© 2025 mark allen. All rights reserved.
