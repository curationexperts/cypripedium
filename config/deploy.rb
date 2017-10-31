# config valid only for current version of Capistrano
lock "3.9.1"

set :application, "cypripedium"
set :repo_url, "https://github.com/curationexperts/cypripedium.git"
set :deploy_to, '/opt/cypripedium'

set :log_level, :debug
set :bundle_flags, '--deployment'
set :bundle_env_variables, nokogiri_use_system_libraries: 1

set :keep_releases, 5
set :assets_prefix, "#{shared_path}/public/assets"

SSHKit.config.command_map[:rake] = 'bundle exec rake'

# Default branch is :master
set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'

append :linked_dirs, "log"
append :linked_dirs, "public/assets"

append :linked_files, "config/database.yml"
append :linked_files, "config/secrets.yml"

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

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
