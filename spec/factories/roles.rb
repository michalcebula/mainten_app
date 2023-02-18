# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    trait :superuser do
      name { 'superuser' }
    end

    trait :engineer do
      name { 'engineer' }
    end

    trait :leader do
      name { 'leader' }
    end

    trait :operator do
      name { 'operator' }
    end
  end
end
