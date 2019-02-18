# frozen_string_literal: true

# deploys to dce qa
set :stage, :dce_qa
set :rails_env, 'production'
server 'cypripedium-qa.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, ".env.production"
