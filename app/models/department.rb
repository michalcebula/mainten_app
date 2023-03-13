# frozen_string_literal: true

class Department < ApplicationRecord
  belongs_to :customer
  has_many :user_departments
  has_many :users, through: :user_departments

  validates_presence_of :name
end
