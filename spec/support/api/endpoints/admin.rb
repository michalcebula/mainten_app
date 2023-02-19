# frozen_string_literal: true

RSpec.shared_examples 'admin endpoint' do
  let(:unpermitted_user) { create(:user, admin?: false) }

  it 'returns unauthorized status if user is unpermitted' do
    allow(Services::Authorization::JWTAuth).to receive(:decode)
    allow_any_instance_of(Api::V1::Admin::BaseController).to receive(:current_user).and_return(unpermitted_user)

    subject

    expect(response).to have_http_status(:unauthorized)
  end
end
