# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Customers', type: :request do
  let(:admin) { create(:user, :admin, :superuser, customer: build(:customer)) }

  describe '#index' do
    subject { get path, params:, as: :json }

    let(:params) { {} }
    let(:path) { '/api/v1/admin/customers' }
    let(:response_body) { JSON.parse(response.body)['data'] }

    context 'when unauthorized' do
      it_behaves_like 'index endpoint'
      it_behaves_like 'admin endpoint'
    end

    context 'when authorized' do
      before do
        allow_any_instance_of(Api::V1::Admin::BaseController).to receive(:authenticate_request)
        allow_any_instance_of(Api::V1::Admin::CustomersController).to receive(:current_user).and_return(admin)
      end

      context 'with empty params' do
        it 'returns list of active customers' do
          create_list(:customer, 2)
          create(:customer, :inactive)

          subject

          expect(response.status).to eq 200
          expect(response_body.count).to eq 3
          expect(response_body.first).to include('type', 'attributes', 'id')
          expect(response_body.last['attributes']).to include('name', 'active?', 'currency')
        end

        it 'returns pagination metadata' do
          create_list(:customer, 2)

          subject
          pagination_metadata = JSON.parse(response.body)['meta']

          expect(response.status).to eq 200
          expect(pagination_metadata).to include('page', 'items_per_page', 'total_pages', 'total_count')
          expect(pagination_metadata['page']).to eq 1
          expect(pagination_metadata['total_pages']).to eq 1
          expect(pagination_metadata['total_count']).to eq 3
          expect(pagination_metadata['items_per_page']).to eq 20
        end
      end

      context 'with inactive_included param set true' do
        let(:params) { { inactive_included: true } }

        it 'returns list of all customers if inactive_included param is truthy' do
          create_list(:customer, 2)
          create(:customer, :inactive)

          subject

          expect(response.status).to eq 200
          expect(response_body.count).to eq 4
          expect(response_body.first).to include('type', 'attributes', 'id')
          expect(response_body.last['attributes']).to include('name', 'active?', 'currency')
        end
      end
    end
  end

  describe '#show' do
    subject { get path }

    let(:customer) { create(:customer, :inactive) }
    let(:path) { "/api/v1/admin/customers/#{customer.id}" }
    let(:response_body) { JSON.parse(response.body)['data'] }

    context 'when unauthorized' do
      it_behaves_like 'index endpoint'
      it_behaves_like 'admin endpoint'
    end

    context 'when authorized' do
      before do
        allow_any_instance_of(Api::V1::Admin::BaseController).to receive(:authenticate_request)
        allow_any_instance_of(Api::V1::Admin::CustomersController).to receive(:current_user).and_return(admin)
      end

      it 'returns user data when customer exist' do
        subject

        expect(response.status).to eq 200
        expect(response_body).to include('type', 'attributes', 'id')
        expect(response_body['attributes']).to include('name', 'active?', 'currency')
      end

      it 'returns error message when customer does not exist' do
        get '/api/v1/admin/customers/invalid_id'

        expect(response.status).to eq 404
        expect(JSON.parse(response.body)).to eq({ 'errors' => ["Couldn't find Customer with 'id'=invalid_id"],
                                                  'status' => 'not_found' })
      end
    end
  end

  describe '#create' do
    subject { post path, params:, as: :json }

    let(:path) { '/api/v1/admin/customers' }
    let(:params) { {} }
    let(:response_body) { JSON.parse(response.body)['data'] }

    context 'when unauthorized' do
      it_behaves_like 'index endpoint'
      it_behaves_like 'admin endpoint'
    end

    context 'when authorized' do
      before do
        allow_any_instance_of(Api::V1::Admin::BaseController).to receive(:authenticate_request)
        allow_any_instance_of(Api::V1::Admin::CustomersController).to receive(:current_user).and_return(admin)
      end

      context 'when params are valid and customer is permitted' do
        let(:params) do
          {
            name: 'test_customer',
            currency: 'USD',
            active: true
          }
        end

        it 'crates customer' do
          expect { subject }.to change(Customer, :count).by(1)
          expect(response.status).to eq 201
          expect(response_body).to include('type', 'attributes', 'id')
          expect(response_body['attributes']).to include(
            'name' => 'test_customer',
            'currency' => 'USD',
            'active?' => true
          )
        end
      end

      context 'when params are invalid' do
        it 'returns 422 response with error messages' do
          expect { subject }.to_not change(Customer, :count)
          expect(response.status).to eq 422
          expect(JSON.parse(response.body)['errors']).to contain_exactly("Name can't be blank")
        end
      end
    end
  end

  describe '#destroy' do
    subject { delete path }

    let!(:customer) { create(:customer) }
    let(:user) { create(:user, :superuser, customer:) }
    let(:path) { "/api/v1/admin/customers/#{customer.id}" }
    let(:response_body) { JSON.parse(response.body)['data'] }

    context 'when unauthorized' do
      it_behaves_like 'index endpoint'
      it_behaves_like 'admin endpoint'
    end

    context 'when authorized' do
      before { allow_any_instance_of(Api::V1::Admin::BaseController).to receive(:authenticate_request) }

      it 'returns user data when customer exist' do
        allow_any_instance_of(Api::V1::Admin::BaseController).to receive(:current_user).and_return(user)

        expect { subject }.to change(Customer, :count).by(-1)

        expect(response.status).to eq 200
        expect(response_body).to include('type', 'attributes', 'id')
        expect(response_body['attributes']).to include('name', 'currency', 'active?')
      end

      it 'returns error message when customer does not exist' do
        allow_any_instance_of(Api::V1::Admin::BaseController)
          .to receive(:current_user)
          .and_raise(ActiveRecord::RecordNotFound)

        delete '/api/v1/admin/users/invalid_id'

        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe '#update' do
    subject { put path, params:, as: :json }

    let!(:customer) { create(:customer, name: 'name', currency: 'PLN', active?: true) }
    let(:params) { {} }
    let(:path) { "/api/v1/admin/customers/#{customer.id}" }
    let(:response_body) { JSON.parse(response.body)['data'] }

    context 'when unauthorized' do
      it_behaves_like 'index endpoint'
      it_behaves_like 'admin endpoint'
    end

    context 'when authorized' do
      before { allow_any_instance_of(Api::V1::Admin::BaseController).to receive(:authenticate_request) }

      context 'when params are valid' do
        let(:params) { { name: 'test_customer', currency: 'USD', active: false } }

        it 'updates customer' do
          expect { subject }.to change(Customer, :count).by(0)
          expect(response.status).to eq 200
          expect(response_body).to include('type', 'attributes', 'id')
          expect(customer.reload.attributes).to include('active?' => params[:active],
                                                        'name' => params[:name],
                                                        'currency' => params[:currency])
        end
      end

      context 'when params are empty' do
        it 'returns 400 status with error message' do
          expect { subject }.to_not change(Customer, :count)
          expect(customer).to eq(customer.reload)
          expect(response.status).to eq 400
          expect(response.body).to eq JSON.dump({ errors: ['Invalid params'], status: 'bad_request' })
        end
      end

      context 'when customer does not exist' do
        let(:path) { '/api/v1/admin/customers/invalid_id' }
        let(:params) { { name: 'some name' } }

        it 'returns 404 status with error message' do
          expect { subject }.to_not change(customer, :attributes)
          expect(response.status).to eq 404
          expect(JSON.parse(response.body)['errors']).to be_present
        end
      end

      context 'when params are invalid' do
        let(:params) { { name: '', currency: 'Dollar' } }

        it 'returns 422 response with error messages' do
          expect { subject }.to_not change(customer, :attributes)
          expect(response.status).to eq 422
          expect(JSON.parse(response.body)['errors']).to contain_exactly("Name can't be blank",
                                                                         'Currency is not included in the list')
        end
      end
    end
  end
end
