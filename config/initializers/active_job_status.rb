# frozen_string_literal: true

ActiveJobStatus.store = :redis_cache_store, { url: ENV['REDIS_URL'].presence || '127.0.0.1' }
