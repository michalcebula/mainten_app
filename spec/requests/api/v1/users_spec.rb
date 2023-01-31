# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  describe '#index' do
    subject { get path }

    let(:path) { '/api/v1/users' }

    context 'when unauthorized' do
      it_behaves_like 'index endpoint'
    end

    context 'when authorized' do
      before { allow_any_instance_of(Api::V1::BaseController).to receive(:authenticate_request) }

      it 'returns users list when users exist' do
        create_list(:user, 3)
        subject

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq User.all.as_json
      end

      it 'returns an empty list when users do not exist' do
        subject

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq []
      end
    end
  end

  describe '#show' do
    subject { get path }

    let(:user) { create(:user) }
    let(:path) { "/api/v1/users/#{user.id}" }

    context 'when unauthorized' do
      it_behaves_like 'show endpoint'
    end

    context 'when authorized' do
      before { allow_any_instance_of(Api::V1::BaseController).to receive(:authenticate_request) }

      it 'returns user data when user exist' do
        subject

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq user.as_json
      end

      it 'returns error message when user does not exist' do
        get '/api/v1/users/invalid_id'

        expect(response.status).to eq 404
        expect(response.body).to eq JSON.dump({ errors: ["Couldn't find User with 'id'=invalid_id"] })
      end
    end
  end

  describe '#create' do
    subject { post path, params: }

    let(:path) { '/api/v1/users' }

    context 'when params are valid' do
      let(:params) do
        {
          username: 'test_user',
          password: 'test_password',
          password_confirmation: 'test_password',
          email: 'test@example.com',
          first_name: 'test',
          last_name: 'example'
        }
      end

      it 'crates user' do
        expect { subject }.to change(User, :count).by(1)
        expect(response.status).to eq 201
        expect(JSON.parse(response.body)).to include(
          'username' => 'test_user',
          'email' => 'test@example.com',
          'first_name' => 'test',
          'last_name' => 'example'
        )
      end
    end

    context 'when params are invalid' do
      let(:params) { {} }

      it 'returns 422 response with error messages' do
        expect { subject }.to_not change(User, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to include(
          "Password can't be blank",
          "Email can't be blank",
          "Password can't be blank",
          "First name can't be blank",
          "Last name can't be blank",
          "Username can't be blank",
          'Email is invalid',
          'Password is too short (minimum is 8 characters)'
        )
      end
    end
  end

  describe '#destroy' do
    subject { delete path }

    let!(:user) { create(:user) }
    let(:path) { "/api/v1/users/#{user.id}" }

    context 'when unauthorized' do
      it_behaves_like 'destroy endpoint'
    end

    context 'when authorized' do
      before { allow_any_instance_of(Api::V1::BaseController).to receive(:authenticate_request) }

      it 'returns user data when user exist' do
        allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)

        expect { subject }.to change(User, :count).by(-1)

        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq user.as_json
      end

      it 'returns error message when user does not exist' do
        allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_raise(ActiveRecord::RecordNotFound)

        delete '/api/v1/users/invalid_id'

        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe '#update' do
    subject { put path, params:, as: :json }

    let!(:user) { create(:user) }
    let(:path) { "/api/v1/users/#{user.id}" }

    context 'when unauthorized' do
      it_behaves_like 'update endpoint'
    end

    context 'when authorized' do
      before { allow_any_instance_of(Api::V1::BaseController).to receive(:authenticate_request) }

      context 'when params are valid' do
        let(:params) { { username: 'new_username' } }

        it 'updates user' do
          allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)

          expect { subject }
            .to change(user, :username).to('new_username')
            .and change(User, :count).by(0)
          expect(response.status).to eq 200
          expect(JSON.parse(response.body)).to eq user.as_json
        end
      end

      context 'when params are empty' do
        let(:params) { {} }

        it 'returns 400 status with error message' do
          allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)

          expect { subject }.to_not change(User, :count)
          expect(user).to eq(user.reload)
          expect(response.status).to eq 400
          expect(response.body).to eq JSON.dump({ errors: ['invalid params'] })
        end
      end

      context 'when user does not exist' do
        let(:path) { '/api/v1/users/invalid_id' }
        let(:params) { { username: 'some_username' } }

        it 'returns 404 status with error message' do
          allow_any_instance_of(Api::V1::BaseController)
            .to receive(:current_user)
            .and_raise(ActiveRecord::RecordNotFound)

          subject

          expect(response.status).to eq 404
          expect(JSON.parse(response.body)['errors']).to be_present
        end
      end
    end
  end
end
