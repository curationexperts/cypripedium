# deploys to DCE sandbox
set :stage, :internal_vm
set :rails_env, 'production'
server '127.0.0.1', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, "config/environments/production.rb"
