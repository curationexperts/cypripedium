# frozen_string_literal: true

# config valid only for current version of Capistrano
lock "3.11.0"

set :application, "cypripedium"
set :repo_url, "https://github.com/MPLSFedResearch/cypripedium.git"
set :deploy_to, '/opt/cypripedium'
set :ssh_options, keys: ["cypripedium-cd-deploy"] if File.exist?("cypripedium-cd-deploy")

set :log_level, :error
set :bundle_flags, '--deployment'
set :bundle_env_variables, nokogiri_use_system_libraries: 1

set :keep_releases, 3
set :assets_prefix, "#{shared_path}/public/assets"

SSHKit.config.command_map[:rake] = 'bundle exec rake'

# Default branch is :master
set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'

append :linked_dirs, "log"
append :linked_dirs, "public/assets"

append :linked_files, "config/database.yml"
append :linked_files, "config/secrets.yml"
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

# We have to re-define capistrano-sidekiq's tasks to work with
# systemctl in production. Note that you must clear the previously-defined
# tasks before re-defining them.
Rake::Task["sidekiq:stop"].clear_actions
Rake::Task["sidekiq:start"].clear_actions
Rake::Task["sidekiq:restart"].clear_actions
namespace :sidekiq do
  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, :sidekiq
    end
  end
  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, :start, :sidekiq
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, :sidekiq
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
