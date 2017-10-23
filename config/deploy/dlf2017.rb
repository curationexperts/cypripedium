# deploys to DCE sandbox
set :stage, :dlf2017
set :rails_env, 'production'
server 'dlf2017.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, "config/environments/production.rb"
