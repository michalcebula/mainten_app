# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSerializer do
  describe '#serializable_hash' do
    subject { described_class.new(user) }

    let(:user) { create(:user) }
    let(:expected_result) do
      {
        data:
        {
          id: user.id,
          type: :user,
          attributes:
          {
            username: user.username,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name
          }
        }
      }
    end

    it 'returns serializerd user data' do
      expect(subject.serializable_hash).to eq expected_result
    end
  end
end
