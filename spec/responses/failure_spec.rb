# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Responses::Failure do
  context 'without specifed parameters' do
    let(:response) { described_class.new }

    it 'returns empty response with defaut status' do
      stub_const('Responses::Failure::ERROR_MESSAGE', 'error message')
      response = subject

      expect(response.body).to eq({ errors: ['error message'], status: 'internal_server_error' })
      expect(response.status).to eq :internal_server_error
    end
  end

  context 'with status and body' do
    let(:response) { described_class.new(status:, body:) }
    let(:status) { :bad_request }
    let(:body) { ['error message', 'another error message'] }

    it 'returns response with bad_request status and error messages' do
      expect(response.body).to eq({ errors: body, status: 'bad_request' })
      expect(response.status).to eq status
    end
  end

  context 'when empty parameter is set to true' do
    let(:response) { described_class.new(empty: true) }

    it 'returns failure status with an empty body' do
      expect(response.body).to be_empty
      expect(response.status).to eq :internal_server_error
    end
  end
end
