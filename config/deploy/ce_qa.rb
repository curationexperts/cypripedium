# deploys to dce qa
set :stage, :ce_qa
set :rails_env, 'production'
server 'cypripedium-qa.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
