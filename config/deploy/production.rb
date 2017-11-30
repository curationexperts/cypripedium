# deploys to FRBM AWS production
set :stage, :production
set :rails_env, 'production'
server '34.226.154.97', user: 'deploy', roles: [:web, :app, :db]
