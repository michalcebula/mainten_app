# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Authentications', type: :request do
  let(:path) { '/api/v1/authentications' }

  describe '#create' do
    subject { post path, params: }

    context 'when params are valid' do
      let(:user) { create(:user, username: 'test_user', password: 'test_password') }
      let(:params) { { username: user.username, password: 'test_password' } }

      it 'returns auth token' do
        subject

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['data']).to include('token')
      end
    end

    context 'when params are invalid' do
      let(:path) { '/api/v1/authentications' }
      let(:params) { { username: 'invalid_username', password: 'invalid_password' } }

      it 'returns auth token' do
        subject

        expect(response.status).to eq 401
        expect(response.body).to eq JSON.dump({ errors: ['Unauthorized'], status: 'unauthorized' })
      end
    end
  end

  describe '#destroy' do
    context 'when unauthorized' do
      it_behaves_like 'destroy endpoint'
    end

    context 'when authorized' do
      subject { delete path, headers: { 'Authorization' => "Bearer #{token}" } }

      let(:token) do
        'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiYTQxZjhmOTItYzk0Zi00OWRhLWJjMzktNWQ4YTE5N2RiNTFiIiwiZXhwIjoxNjc1NjI2NDM4fQ.3KzlB93GJqivVjbXXDfRfndWmzrQYkSBwGVH8_saNKk' # rubocop:disable Layout/LineLength
      end

      before do
        stub_const('REDIS_BLACKLIST', MockRedis.new)
        allow_any_instance_of(Api::V1::BaseController).to receive(:authenticate_request)
      end

      it 'expires token' do
        subject

        expect(REDIS_BLACKLIST.get(token)).to eq 'expired'
        expect(response.status).to eq 200
        expect(response.body).to be_empty
      end
    end
  end
end
