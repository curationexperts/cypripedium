# deploys to DCE sandbox
set :stage, :sandbox
set :rails_env, 'production'
server 'cypripedium.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
