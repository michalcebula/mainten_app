# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates_presence_of :email, :password, :first_name, :last_name, :username
  validates_uniqueness_of :email, :username

  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates :password, length: { in: 8..50 }
end
