# deploys to dce cd
set :stage, :dce_cd
set :rails_env, 'production'

server 'cypripedium-cd.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, ".env.production"

# Capistrano passenger restart isn't working consistently,
# so restart apache2 after a successful deploy, to ensure
# changes are picked up.
namespace :deploy do
  after :finishing, :restart_apache do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, :apache2
    end
  end
end
