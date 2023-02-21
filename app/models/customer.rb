# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :users, dependent: :destroy

  validates_presence_of :name, :currency
  validates :currency, inclusion: { in: %w[PLN EUR USD] }
end
