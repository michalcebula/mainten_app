# frozen_string_literal: true

module Api
  class UserPolicy
    class << self
      def show?(user, id)
        user.id == id || user.admin?
      end

      def index?(user)
        user.admin?
      end

      def create?(user)
        return true if user.admin?

        permited_roles = %w[superuser leader]
        user.roles.any? { |role| role.name.in? permited_roles }
      end

      alias destroy? show?
      alias update? show?
    end
  end
end
