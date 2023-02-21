# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :customer
  has_many :role_assignments
  has_many :roles, through: :role_assignments

  has_secure_password

  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates :password, presence: true, on: :create
  validates :password, length: { in: 8..50 }, if: -> { password.present? }
  validates_presence_of :email, :first_name, :last_name, :username
  validates_uniqueness_of :email, :username, if: -> { password.present? }
end
