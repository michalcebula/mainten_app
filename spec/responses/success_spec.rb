# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Responses::Success do
  context 'without specifed parameters' do
    let(:response) { described_class.new }

    it 'returns empty response with defaut status' do
      stub_const('DEFAULT_STATUS', :ok)
      response = subject

      expect(response.body).to be_empty
      expect(response.status).to eq :ok
    end
  end

  context 'with status, body and serializer' do
    let(:response) { described_class.new(status:, body:, serializer:) }
    let(:status) { :created }
    let(:body) { build_stubbed(:user) }
    let(:serialized_body) { body.attributes.slice('first_name', 'last_name') }
    let(:serializer) { double(:fake_serializer) }

    before do
      allow(serializer).to receive(:new).with(body).and_return(serialized_body)
    end

    it 'returns response with created status and serialized body' do
      expect(serializer).to receive(:new).with(body).and_return(serialized_body)

      expect(response.body).to eq serialized_body
      expect(response.status).to eq :created
    end
  end
end
