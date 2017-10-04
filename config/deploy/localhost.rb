# deploys to DCE sandbox
set :stage, :localhost
set :rails_env, 'production'
server '34.227.251.196', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, "config/environments/production.rb"
