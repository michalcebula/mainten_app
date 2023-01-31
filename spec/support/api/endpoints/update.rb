# frozen_string_literal: true

RSpec.shared_examples 'update endpoint' do
  subject { put path, headers: }

  it_behaves_like '401 unauthorized'
end
