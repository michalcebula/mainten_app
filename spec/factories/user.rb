# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "foo#{n}@bar.com" }
    sequence(:username) { |n| "foobar#{n}" }
    sequence(:first_name) { |n| "foo#{n}" }
    sequence(:last_name)  { |n| "bar#{n}" }
    sequence(:password) { |n| "password#{n}" }

    trait :admin do
      admin? { true }
    end

    trait :superuser do
      after(:create) do |user|
        role = Role.find_by(name: 'superuser') || FactoryBot.create(:role, :superuser)
        user.roles << role
      end
    end
  end
end
