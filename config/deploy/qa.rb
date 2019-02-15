# deploys to FRBM AWS qa
set :stage, :qa
set :rails_env, 'production'
server '54.164.99.127', user: 'deploy', roles: [:web, :app, :db]
