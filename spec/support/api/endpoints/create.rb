# frozen_string_literal: true

RSpec.shared_examples 'create endpoint' do
  subject { post path, headers: }

  it_behaves_like '401 unauthorized'
end
