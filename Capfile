# frozen_string_literal: true

# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require "capistrano/deploy"

# Use RBENV to manage ruby version in use
require 'capistrano/rbenv'

# Use bundler to install gem requirements
require 'capistrano/bundler'

require 'capistrano/rails'
require 'capistrano/passenger'

# Sidekiq integration - https://github.com/seuros/capistrano-sidekiq
require 'capistrano/sidekiq'
install_plugin Capistrano::Sidekiq # Default sidekiq tasks
install_plugin Capistrano::Sidekiq::Systemd
set :sidekiq_service_unit_user, :system # Run Sidekiq as a system service

# Load the SCM plugin appropriate to your project:
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# require "capistrano/rvm"
# require "capistrano/rbenv"
# require "capistrano/chruby"
# require "capistrano/bundler"
# require "capistrano/rails/assets"
# require "capistrano/rails/migrations"
# require "capistrano/passenger"

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

require 'capistrano/honeybadger'
# use whenever to manage cron jobs
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"
