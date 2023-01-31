# frozen_string_literal: true

RSpec.shared_examples 'destroy endpoint' do
  subject { delete path, headers: }

  it_behaves_like '401 unauthorized'
end
