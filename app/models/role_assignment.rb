# frozen_string_literal: true

class RoleAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :role
end
