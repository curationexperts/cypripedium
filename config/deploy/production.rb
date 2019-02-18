# frozen_string_literal: true

# deploys to FRBM AWS production
set :stage, :production
set :rails_env, 'production'
server '3.208.81.15', user: 'deploy', roles: [:web, :app, :db]
