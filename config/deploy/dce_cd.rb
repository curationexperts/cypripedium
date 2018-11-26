# deploys to dce qa
set :stage, :dce_cd
set :rails_env, 'production'
server 'cypripedium-cd.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, ".env.production"
