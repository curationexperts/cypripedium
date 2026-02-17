require 'runtime_info'

Rack::MiniProfiler.config.authorization_mode = :allow_all unless RuntimeInfo.environment == 'EC2:Production'

Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore
# Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
# Rack::MiniProfiler.config.storage_options = {
#   connection: Redis.current
# }
