# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Responses::NotFound do
  let(:response) { described_class.new }

  it 'returns not_found status with error message' do
    expect(response.body).to eq({ errors: ['Not found'], status: 'not_found' })
    expect(response.status).to eq :not_found
  end
end
