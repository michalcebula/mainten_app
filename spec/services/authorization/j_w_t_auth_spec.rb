# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::Authorization::JWTAuth do
  subject { Services::Authorization::JWTAuth }

  let(:fake_jwt) { double(:jwt) }
  let(:fake_time) { double(:time) }

  before(:each) { stub_const('Services::Authorization::JWTAuth::SECRET_KEY', 'secret key') }

  describe '#encode' do
    let(:payload) { { user_id: '173de81c-563c-4eec-b124-c3301a9626cd' } }

    before do
      stub_const('JWT', fake_jwt)
      stub_const('Time', fake_time)
      stub_const('Services::Authorization::JWTAuth::EXPIRATION_TIME', 10)
      allow(fake_time).to receive_message_chain(:now, :to_i).and_return(10)
      allow(fake_jwt).to receive(:encode)
    end

    it 'encodes payload' do
      expect(fake_jwt).to receive(:encode).with(payload.merge(exp: 20), 'secret key').once

      subject.encode(payload)
    end
  end

  describe '#decode' do
    let(:token) { 'token' }

    before(:each) { stub_const('REDIS_BLACKLIST', MockRedis.new) }

    it 'raises error if token is blacklisted' do
      REDIS_BLACKLIST.set(token, 'expired')

      expect { subject.decode(token) }.to raise_error(JWT::ExpiredSignature)
    end

    it 'decodes token' do
      stub_const('JWT', fake_jwt)
      allow(fake_jwt).to receive(:decode)
      expect(fake_jwt).to receive(:decode).with(token, 'secret key').and_return([{ user_id: 'id' }]).once

      subject.decode(token)
    end
  end

  describe '#expire' do
    before do
      stub_const('REDIS_BLACKLIST', MockRedis.new)
      stub_const('Services::Authorization::JWTAuth::EXPIRATION_TIME', 10)
    end

    it 'expires token' do
      expect(REDIS_BLACKLIST.get('token')).to be_nil

      subject.expire('token')

      expect(REDIS_BLACKLIST.get('token')).to eq 'expired'
      expect(REDIS_BLACKLIST.ttl('token')).to be > 0
    end
  end
end
