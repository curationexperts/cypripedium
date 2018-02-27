# deploys to FRBM AWS staging
set :stage, :staging
set :rails_env, 'production'
server '34.207.158.90', user: 'deploy', roles: [:web, :app, :db]
