# frozen_string_literal: true

RSpec.shared_examples '401 unauthorized' do
  let(:headers) { { 'Authorization' => 'Bearer invalid_token' } }

  it 'returns 401 response with authorization error message' do
    subject

    expect(response.body).to eq(JSON.dump({ errors: ['Unauthorized'], status: 'unauthorized' }))
    expect(response.status).to eq 401
  end
end
