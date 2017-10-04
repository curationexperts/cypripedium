# deploys to DCE sandbox
set :stage, :sandbox
set :rails_env, 'production'
server '34.231.187.95', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, "config/environments/production.rb"
