# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDepartment, type: :model do
  it 'validates presence of user_id and department_id' do
    user_department = UserDepartment.new(user_id: nil, department_id: nil)

    expect(user_department).to be_invalid
    expect(user_department.errors.full_messages).to include('User must exist', 'Department must exist')
  end

  it 'validates if user and department belongs to the same customer' do
    user = create(:user, customer: create(:customer, name: 'some customer'))
    department = create(:department, customer: create(:customer, name: 'other customer'))
    user_department = UserDepartment.new(user: user, department: department)

    expect(user_department).to be_invalid
    expect(user_department.errors.full_messages).to contain_exactly "User and Department must belong to the same Customer"
  end
end
