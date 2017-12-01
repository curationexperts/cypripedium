# deploys to FRBM AWS qa
set :stage, :qa
set :rails_env, 'production'
server '52.202.30.56', user: 'deploy', roles: [:web, :app, :db]
