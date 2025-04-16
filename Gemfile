# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.4'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'bagit'
gem 'bcrypt_pbkdf', '~> 1.1' # Needed to support more secure ssh keys
gem 'bixby'
gem "blacklight_range_limit", '~> 7.0'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 4.0'
gem 'citeproc-ruby'
gem 'coffee-rails', '~> 4.2'
gem 'concurrent-ruby', '1.3.4'
gem 'csl-styles'
gem 'dalli'
gem 'dartsass-sprockets'
gem 'devise'
gem 'devise-guests', '~> 0.8'
gem 'dotenv-rails'
gem 'ed25519', '~> 1.2', '>= 1.2.4'
gem 'grpc', '~> 1.59.3'
gem 'honeybadger'
gem 'hydra-role-management'
gem 'hyrax', '~> 5.0', '>= 5.0.4'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'parser'
gem 'pg', '~> 1.3'
gem 'puma'
gem 'rails', '~> 6.1'
# Support semantic logs in JSON format [https://logger.rocketjob.io/rails.html]
gem 'rails_semantic_logger'
gem 'redcarpet'
gem 'riiif', '~> 2.1'
gem 'rsolr', '>= 1.0', '< 3'
gem 'rubyzip', '~> 1.0', require: 'zip'
gem 'sidekiq', '< 8'
gem 'solrizer'
gem 'strscan', '1.0.3' # match version installed on server as system gem
gem 'terser'
gem 'tether-rails'
gem 'turbolinks', '~> 5'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'uglifier', '>= 1.3.0'
gem 'whenever', require: false

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-ext'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq'
  gem 'listen'
  gem 'web-console', '~> 3.7'
  gem 'xray-rails'
  gem 'yard'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'faker'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'webdrivers'
end
