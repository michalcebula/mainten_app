# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  let(:role) { create(:role, :superuser) }

  it 'has a valid factory' do
    expect(role).to be_valid
  end

  it 'validates name presence' do
    role = Role.new(name: nil)

    expect(role).to be_invalid
    expect(role.errors.full_messages).to include("Name can't be blank")
  end

  it 'validates name uniqueness' do
    role

    expect(Role.new(name: 'superuser')).to be_invalid
  end

  it 'validates name value' do
    expect(Role.new(name: 'invalid_name')).to be_invalid
  end
end
