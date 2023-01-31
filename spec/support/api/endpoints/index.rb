# frozen_string_literal: true

RSpec.shared_examples 'index endpoint' do
  subject { get path, headers: }

  it_behaves_like '401 unauthorized'
end
