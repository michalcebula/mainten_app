# frozen_string_literal: true

class CustomerSerializer
  include JSONAPI::Serializer

  set_type :customer
  set_id :id

  attributes :name, :currency, :active?
end
