# frozen_string_literal: true

class UserDepartment < ApplicationRecord
  belongs_to :user, dependent: :destroy
  belongs_to :department, dependent: :destroy

  validates_presence_of :user_id, :department_id
  validate :user_and_department_must_belong_to_same_customer

  def user_and_department_must_belong_to_same_customer
    return if user.nil? || department.nil?
    return if user.customer_id == department.customer_id

    errors.add(:base, "User and Department must belong to the same Customer")
  end
end