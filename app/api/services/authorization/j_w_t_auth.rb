# frozen_string_literal: true

require 'jwt'

# frozen_string_literal: false

module Services
  module Authorization
    module JWTAuth
      SECRET_KEY = Rails.application.secret_key_base
      EXPIRATION_TIME = Rails.application.credentials.jwt.expiration_time || 3600

      def self.encode(payload)
        payload[:exp] = Time.now.to_i + EXPIRATION_TIME
        JWT.encode(payload, SECRET_KEY)
      end

      def self.decode(token)
        raise JWT::ExpiredSignature if REDIS_BLACKLIST.get(token)

        decoded = JWT.decode(token, SECRET_KEY)
        HashWithIndifferentAccess.new(decoded[0])
      end

      def self.expire(token)
        REDIS_BLACKLIST.setex(token, EXPIRATION_TIME, 'expired')
      end
    end
  end
end
