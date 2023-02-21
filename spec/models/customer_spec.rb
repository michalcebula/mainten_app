# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  let(:customer) { build(:customer) }
  let(:validation_errors) { customer.errors.full_messages }

  it 'has a valid factory' do
    expect(customer).to be_valid
  end

  context 'for a new customer' do
    it 'validates currency format' do
      customer.currency = 'INVALID'

      expect(customer).to be_invalid
      expect(validation_errors).to include('Currency is not included in the list')
    end
  end
end
