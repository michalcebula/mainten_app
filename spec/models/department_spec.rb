# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Department, type: :model do
  it 'has a valid factory' do
    department = create(:department)

    expect(department).to be_valid
  end

  context 'for a new department' do
    it 'validates name presence' do
      department = Department.create(name: nil, customer: create(:customer))
      validation_errors = department.errors.full_messages

      expect(department).to be_invalid
      expect(validation_errors).to include("Name can't be blank")
    end
  end
end
