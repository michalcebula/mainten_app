# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRepository do
  subject { described_class }

  describe '#save' do
    let(:user) { build(:user) }
    let(:invalid_user) { User.new }

    it 'returns true if user was saved' do
      expect(subject.save(user)).to be_truthy
    end

    it 'returns false if user was not saved' do
      expect(subject.save(invalid_user)).to be_falsey
    end
  end

  describe '#find' do
    let!(:user) { create(:user) }

    it 'returns user if exist' do
      expect(subject.find(user.id)).to eq user
    end

    it 'raises error if user does not exist' do
      expect { subject.find('invalid_id') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#find_current_user' do
    let!(:user) { create(:user, :superuser) }

    it 'returns user with preloaded roles if user exist' do
      current_user = subject.find_current_user(user.id)

      expect(current_user).to eq user
      expect(current_user.roles.loaded?).to be_truthy
    end

    it 'returns nil if user does not exist' do
      expect(subject.find_current_user('invalid_id')).to be_nil
    end
  end
end
