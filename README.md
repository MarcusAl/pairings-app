# Pairings API

## API Documentation

View the interactive API documentation:

[![API Documentation](https://img.shields.io/badge/API-Documentation-blue)](https://petstore.swagger.io/?url=https://raw.githubusercontent.com/marcusal/pairings-app/main/pairings-api/swagger/v1/swagger.yaml)

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
