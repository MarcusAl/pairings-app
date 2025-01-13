# README

## System dependencies

Install ruby 3.4.1 with your package manager (mise is recommended)

```
brew install postgresql@14
brew services start postgresql@14
brew install redis
brew services start redis
brew services list
```

##Create a postgres user with password

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
