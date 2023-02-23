# frozen_string_literal: true

class Department < ApplicationRecord
  belongs_to :customer

  validates_presence_of :name
end
