# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Responses::Unpermitted do
  let(:response) { described_class.new }

  it 'returns forbidden status with error message' do
    expect(response.body).to eq({ errors: ['Unpermitted'], status: 'forbidden' })
    expect(response.status).to eq :forbidden
  end
end
