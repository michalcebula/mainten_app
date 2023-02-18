# frozen_string_literal: true

class Role < ApplicationRecord
  ROLES = %w[superuser engineer leader operator].freeze

  has_many :role_assignments
  has_many :users, through: :role_assignments

  validates :name, presence: true, uniqueness: true, inclusion: { in: ROLES }
end
