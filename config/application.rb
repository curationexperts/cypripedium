# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cypripedium
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.active_job.queue_adapter = :sidekiq
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    Rails.application.configure do
      config.rdf_uri = ENV['RDF_URI'] || 'https://researchdatabase.minneapolisfed.org'

      config.bag_prefix = 'mpls_fed_research'
      config.bag_path = ENV['BAG_PATH'] || Rails.root.join('tmp', 'bags')
    end

    # Output logs in JSON format
    config.rails_semantic_logger.format = :json
    config.semantic_logger.application = Rails.application.class.module_parent_name

    config.after_initialize do
      # Override collection form class so that we can
      # add markdown to some of the fields in the form.
      Hyrax::Forms::CollectionForm.prepend ::CollectionFormMarkdown

      # Cypripedium needs its own local schema.org config to handle microdata settings
      # for fields that are not configured in base Hyrax, e.g., "alpha_creator"
      Hyrax::Microdata.load_paths << Rails.root.join('config', 'schema_org.yml')
    end
  end
end
