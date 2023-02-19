# frozen_string_literal: true

class UserRepository
  class << self
    def save(user)
      user.save
    end

    def find(id)
      User.find(id)
    end

    def find_current_user(id)
      User.includes(:roles).find(id)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def all
      User.includes(:roles).all
    end
  end
end
