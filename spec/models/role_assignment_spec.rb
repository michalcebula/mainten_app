# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoleAssignment, type: :model do
  it 'validates presence of user_id and role_id' do
    role_assignment = RoleAssignment.new(user_id: nil, role_id: nil)

    expect(role_assignment).to be_invalid
    expect(role_assignment.errors.full_messages).to include('User must exist', 'Role must exist')
  end
end
