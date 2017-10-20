# deploys to DCE sandbox
set :stage, :localhost
set :rails_env, 'production'
server '54.80.236.34', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, "config/environments/production.rb"
