# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Responses::Unauthorized do
  let(:response) { described_class.new }

  it 'returns unauthorized status with error message' do
    expect(response.body).to eq({ errors: ['Unauthorized'], status: 'unauthorized' })
    expect(response.status).to eq :unauthorized
  end
end
