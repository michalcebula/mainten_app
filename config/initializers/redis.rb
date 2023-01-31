# frozen_string_literal: true

REDIS_BLACKLIST = Redis.new(host: Rails.application.credentials.redis.host)