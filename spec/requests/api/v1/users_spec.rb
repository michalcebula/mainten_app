# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  describe '#show' do
    subject { get path }

    let(:user) { create(:user) }
    let(:path) { "/api/v1/users/#{user.id}" }
    let(:response_body) { JSON.parse(response.body)['data'] }

    context 'when unauthorized' do
      it_behaves_like 'show endpoint'
    end

    context 'when authorized' do
      before do
        allow_any_instance_of(Api::V1::BaseController).to receive(:authenticate_request)
        allow_any_instance_of(Api::V1::UsersController).to receive(:current_user).and_return(user)
      end

      it 'returns user data when user exist' do
        subject

        expect(response.status).to eq 200
        expect(response_body).to include('type', 'attributes', 'id')
        expect(response_body['attributes']).to include('first_name', 'last_name', 'username', 'email')
        expect(response_body['relationships']).to include('roles')
      end

      it 'returns error message when user does not exist' do
        get '/api/v1/users/invalid_id'

        expect(response.status).to eq 404
        expect(JSON.parse(response.body)).to eq({ 'errors' => ["Couldn't find User with 'id'=invalid_id"],
                                                  'status' => 'not_found' })
      end
    end
  end

  describe '#create' do
    subject { post path, params: }

    let(:path) { '/api/v1/users' }
    let(:params) { {} }
    let(:response_body) { JSON.parse(response.body)['data'] }

    context 'when unauthorized' do
      it_behaves_like 'create endpoint'

      it 'returns unauthorized status if user is unpermitted' do
        allow_any_instance_of(Api::V1::BaseController).to receive(:authenticate_request)
        allow_any_instance_of(Api::V1::UsersController).to receive(:current_user).and_return(create(:user, :operator))

        subject

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authorized' do
      before { allow_any_instance_of(Api::V1::BaseController).to receive(:authenticate_request) }

      context 'when params are valid and user is permitted' do
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
        let(:user) { create(:user, :superuser) }

        before do
          allow_any_instance_of(Api::V1::UsersController).to receive(:current_user).and_return(user)
        end

        it 'crates user if user is permitted' do
          expect { subject }.to change(User, :count).by(1)
          expect(response.status).to eq 201
          expect(response_body).to include('type', 'attributes', 'id')
          expect(response_body['attributes']).to include(
            'email' => 'test@example.com',
            'first_name' => 'test',
            'last_name' => 'example',
            'username' => 'test_user'
          )
          expect(response_body['relationships']).to include('roles')
        end
      end

      context 'when params are invalid' do
        let(:params) { {} }

        before do
          allow_any_instance_of(Api::V1::UsersController).to receive(:current_user).and_return(create(:user,
                                                                                                      :superuser))
        end

        it 'returns 422 response with error messages' do
          expect { subject }.to_not change(User, :count)
          expect(response.status).to eq 422
          expect(JSON.parse(response.body)['errors']).to include(
            "Email can't be blank",
            "First name can't be blank",
            "Last name can't be blank",
            "Username can't be blank",
            'Email is invalid',
            "Password can't be blank"
          )
        end
      end
    end
  end

  describe '#destroy' do
    subject { delete path }

    let!(:user) { create(:user) }
    let(:path) { "/api/v1/users/#{user.id}" }
    let(:response_body) { JSON.parse(response.body)['data'] }

    context 'when unauthorized' do
      it_behaves_like 'destroy endpoint'
    end

    context 'when authorized' do
      before { allow_any_instance_of(Api::V1::BaseController).to receive(:authenticate_request) }

      it 'returns user data when user exist' do
        allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)

        expect { subject }.to change(User, :count).by(-1)

        expect(response.status).to eq 200
        expect(response_body).to include('type', 'attributes', 'id')
        expect(response_body['attributes']).to include(
          'email' => user.email,
          'first_name' => user.first_name,
          'last_name' => user.last_name,
          'username' => user.username
        )
        expect(response_body['relationships']).to include('roles')
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
    let(:response_body) { JSON.parse(response.body)['data'] }

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
          expect(response_body).to include('type', 'attributes', 'id')
          expect(response_body['attributes']).to include(
            'email' => user.email,
            'first_name' => user.first_name,
            'last_name' => user.last_name,
            'username' => 'new_username'
          )
          expect(response_body['relationships']).to include('roles')
        end
      end

      context 'when params are empty' do
        let(:params) { {} }

        it 'returns 400 status with error message' do
          allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)

          expect { subject }.to_not change(User, :count)
          expect(user).to eq(user.reload)
          expect(response.status).to eq 400
          expect(response.body).to eq JSON.dump({ errors: ['Invalid params'], status: 'bad_request' })
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

      context 'when params are invalid' do
        let(:params) { { email: '', username: '', password: 'pswd', password_confirmation: 'pswd2' } }

        it 'returns 422 response with error messages' do
          allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
          subject

          expect(user.reload.username).to be_present
          expect(user.email).to be_present
          expect(response.status).to eq 422
          expect(JSON.parse(response.body)['errors']).to include(
            "Email can't be blank",
            'Email is invalid',
            "Username can't be blank",
            'Email is invalid',
            'Password is too short (minimum is 8 characters)',
            "Password confirmation doesn't match Password"
          )
        end
      end
    end
  end
end
