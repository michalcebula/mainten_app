# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "customer_#{n}" }
    currency { 'PLN' }

    trait :inactive do
      active? { false }
    end
  end
end
