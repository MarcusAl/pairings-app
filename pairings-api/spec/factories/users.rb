require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :user do
    email { 'foo@bar.com' }
    password { 'Secret1*3*5*' }
    password_confirmation { password }
    verified { true }
  end

  trait :random_email do
    email { "test_#{SecureRandom.uuid}@example.com" }
  end
end
