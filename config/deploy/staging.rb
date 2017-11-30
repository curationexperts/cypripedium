# deploys to FRBM AWS staging
set :stage, :staging
set :rails_env, 'production'
server '54.147.55.67', user: 'deploy', roles: [:web, :app, :db]
