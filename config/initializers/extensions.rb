# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  Dir["./app/extensions/**/*.rb"].each { |f| require f }
end
