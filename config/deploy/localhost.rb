# frozen_string_literal: true

# capistrano bootstrapping deploy, run by ansible
# this *must* be named localhost
set :stage, :localhost
set :rails_env, 'production'
server '127.0.0.1', user: 'deploy', roles: [:web, :app, :db]
