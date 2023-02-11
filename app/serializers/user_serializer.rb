# frozen_string_literal: true

class UserSerializer
  include JSONAPI::Serializer

  set_type :user
  set_id :id
  attributes :username, :email, :first_name, :last_name
end
