# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomerRepository do
  subject { described_class }

  let!(:active_customer) { create(:customer) }
  let!(:inactive_customer) { create(:customer, :inactive) }

  describe '#save' do
    it 'returns true if customer was saved' do
      customer = build(:customer)

      expect(subject.save(customer)).to be_truthy
    end

    it 'returns false if customer was not saved' do
      customer = build(:customer, currency: 'invalid')

      expect(subject.save(customer)).to be_falsey
    end
  end

  describe '#find' do
    it 'returns customer if exist and active' do
      expect(subject.find(active_customer.id)).to eq active_customer
    end

    it 'returns customer when inactive, but inactive_included set to true' do
      expect(subject.find(inactive_customer.id, inactive_included: true)).to eq inactive_customer
    end

    it 'raises RecordNotFound error if customer is inactive' do
      expect { subject.find(inactive_customer.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises RecordNotFound error if customer does not exist' do
      expect { subject.find('invalid_id') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#all' do
    it 'returns list of actvie customers' do
      expect(subject.all).to contain_exactly(active_customer)
    end

    it 'returns list of all customer if inactive_included is set to true' do
      expect(subject.all(inactive_included: true)).to include(active_customer, inactive_customer)
    end
  end
end
