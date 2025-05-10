# frozen_string_literal: true

# config valid only for current version of Capistrano
lock "3.19.2"

set :application, "cypripedium"
set :repo_url, "https://github.com/MPLSFedResearch/cypripedium.git"
set :deploy_to, '/opt/cypripedium'
set :ssh_options, keys: ["cypripedium-cd-deploy"] if File.exist?("cypripedium-cd-deploy")

set :log_level, :error
set :bundle_env_variables, nokogiri_use_system_libraries: 1

# Sidekiq configuration on servers
set :sidekiq_roles, :worker                  # Default role for Sidekiq processes
set :sidekiq_default_hooks, true             # Enable default deployment hooks
set :sidekiq_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage))) # Environment for Sidekiq processes
set :service_unit_user, :system              # We run Sidekiq as a system service to avoid setting up lingering
set :sidekiq_service_unit_name, 'sidekiq'    # Match the service name configured by Ansible

set :keep_releases, 3
set :assets_prefix, "#{shared_path}/public/assets"

SSHKit.config.command_map[:rake] = 'bundle exec rake'

# Default branch is :main
set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || ENV['BRANCH'] || 'main'

append :linked_dirs, "log"
append :linked_dirs, "public/assets"

append :linked_files, "config/database.yml"
append :linked_files, "config/master.key"
append :linked_files, ".env.production"

# after 'deploy:published', 'hyrax:ensure_default_admin_set'

namespace :hyrax do
  desc 'Ensure Hyrax default admin set exists'
  task :ensure_default_admin_set do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'hyrax:default_admin_set:create'
        end
      end
    end
  end
end

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
