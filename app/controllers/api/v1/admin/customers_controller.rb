# frozen_string_literal: true

module Api
  module V1
    module Admin
      class CustomersController < Admin::BaseController
        def index
          inactive_included = ActiveModel::Type::Boolean.new.cast(params[:inactive_included])
          render_response(body: CustomerRepository.all(inactive_included:),
                          serializer: CustomerSerializer, paginated: true)
        end

        def show
          render_response(body: customer, serializer: CustomerSerializer)
        rescue ActiveRecord::RecordNotFound => e
          not_found_response(e)
        end

        def create
          customer = Customer.new(customer_params)

          if CustomerRepository.save(customer)
            render_response(status: :created, body: customer, serializer: CustomerSerializer)
          else
            render json: validation_errors(customer), status: :unprocessable_entity
          end
        end

        def update
          return render_invalid_params if customer_params.empty?

          customer.assign_attributes(customer_params)
          return render_response(body: customer, serializer: CustomerSerializer) if CustomerRepository.save(customer)

          render json: validation_errors(customer), status: :unprocessable_entity
        rescue ActiveRecord::RecordNotFound => e
          not_found_response(e)
        end

        def destroy
          render_response(body: customer, serializer: CustomerSerializer) if customer.destroy!
        rescue ActiveRecord::RecordNotFound => e
          not_found_response(e)
        end

        private

        def customer
          @customer ||= CustomerRepository.find(params.permit(:id)[:id], inactive_included: true)
        end

        def customer_params
          permitted_params = params.permit(%i[name currency active])
          permitted_params[:active?] = ActiveModel::Type::Boolean.new.cast(permitted_params.delete(:active))
          permitted_params.compact
        end
      end
    end
  end
end
