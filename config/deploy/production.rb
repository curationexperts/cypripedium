# deploys to FRBM AWS production
set :stage, :production
set :rails_env, 'production'
server '54.235.59.76', user: 'deploy', roles: [:web, :app, :db]
