# frozen_string_literal: true

# deploys to FRBM AWS production
set :stage, :production
set :rails_env, 'production'
server 'localhost', user: 'deploy', roles: [:web, :app, :db]
