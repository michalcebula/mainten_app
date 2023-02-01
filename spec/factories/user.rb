# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "foo#{n}@bar.com" }
    sequence(:username) { |n| "foobar#{n}" }
    sequence(:first_name) { |n| "foo#{n}" }
    sequence(:last_name)  { |n| "bar#{n}" }
    sequence(:password) { |n| "password#{n}" }
  end
end
