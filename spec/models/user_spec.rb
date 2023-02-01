# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let(:validation_errors) { user.errors.full_messages }

  it 'has a valid factory' do
    expect(user).to be_valid
  end

  it 'validates email format' do
    user.email = 'Invalid@'

    expect(user).to be_invalid
    expect(validation_errors).to include('Email is invalid')
  end

  it 'validates email presence' do
    user.email = nil

    expect(user).to be_invalid
    expect(validation_errors).to include("Email can't be blank")
  end

  it 'validates password presence' do
    user.password = nil

    expect(user).to be_invalid
    expect(validation_errors).to include("Password can't be blank")
  end

  it 'validates username presence' do
    user.username = nil

    expect(user).to be_invalid
    expect(validation_errors).to include("Username can't be blank")
  end

  it 'validates first_name presence' do
    user.first_name = nil

    expect(user).to be_invalid
    expect(validation_errors).to include("First name can't be blank")
  end

  it 'validates last_name presence' do
    user.last_name = nil

    expect(user).to be_invalid
    expect(validation_errors).to include("Last name can't be blank")
  end

  it 'matches password confirmation' do
    user.password = 'password'
    user.password_confirmation = 'password1'

    expect(user).to be_invalid
    expect(validation_errors).to include("Password confirmation doesn't match Password")
  end

  it 'has encrypted password' do
    User.create(email: 'foo@bar.com', username: 'foobar', first_name: 'foo', last_name: 'bar', password: 'password')
    user = User.find_by(email: 'foo@bar.com')

    expect(user.password).to be_nil
    expect(user.password_digest).to_not eq('password')
  end
end
