# frozen_string_literal: true

class UserRepository
  class << self
    def save(user)
      user.save
    end

    def find(id)
      User.find(id)
    end
  end
end
