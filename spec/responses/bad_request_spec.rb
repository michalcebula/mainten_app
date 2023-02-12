# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Responses::BadRequest do
  let(:response) { described_class.new }

  it 'returns bad_request status with error message' do
    expect(response.body).to eq({ errors: ['Invalid params'], status: 'bad_request' })
    expect(response.status).to eq :bad_request
  end
end
