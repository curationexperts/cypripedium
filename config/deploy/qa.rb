# deploys to FRBM AWS qa
set :stage, :qa
set :rails_env, 'production'
server '52.6.24.167', user: 'deploy', roles: [:web, :app, :db]
