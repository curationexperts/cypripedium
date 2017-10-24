# deploys to DCE sandbox
set :stage, :demo
set :rails_env, 'production'
server 'demo.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
