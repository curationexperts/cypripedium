require 'runtime_info'

Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore
Rack::MiniProfiler.config.authorization_mode = :allow_all unless RuntimeInfo.environment == 'EC2:Production'