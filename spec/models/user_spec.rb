# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }
  let(:validation_errors) { user.errors.full_messages }

  context 'for a new user' do
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

    it 'validates password length' do
      user.password = 'pswd'
      user.password_confirmation = 'pswd'

      expect(user).to be_invalid
      expect(validation_errors).to include("Password is too short (minimum is 8 characters)")
    end

    it 'has encrypted password' do
      User.create(email: 'foo@bar.com', username: 'foobar', first_name: 'foo', last_name: 'bar', password: 'password')
      user = User.find_by(email: 'foo@bar.com')

      expect(user.password).to be_nil
      expect(user.password_digest).to_not eq('password')
    end
  end

  context 'for a saved user' do
    before { user.save }

    it 'validates password length' do
      user.assign_attributes(password: 'pswd', password_confirmation: 'pswd')

      expect(user).to be_invalid
      expect(validation_errors).to include("Password is too short (minimum is 8 characters)")
    end

    it 'matches password confirmation' do
      user.assign_attributes(password: 'password', password_confirmation: 'password1')

      expect(user).to be_invalid
      expect(validation_errors).to include("Password confirmation doesn't match Password")
    end

    it 'sets fasle as admin? default' do
      user = User.create(email: 'foo@bar.com', username: 'foobar', first_name: 'foo', last_name: 'bar', password: 'password')

      expect(user.admin?).to be_falsey
    end
  end
end
