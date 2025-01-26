# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  verified        :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
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
