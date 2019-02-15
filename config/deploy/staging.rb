# deploys to FRBM AWS staging
set :stage, :staging
set :rails_env, 'production'
server '18.211.59.195', user: 'deploy', roles: [:web, :app, :db]
