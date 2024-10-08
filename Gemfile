# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.4'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "actionview", ">= 5.1.6.2"
gem 'active_job_status', '~> 1.2.1'
gem 'bagit'
gem 'bcrypt_pbkdf', '~> 1.1' # Needed to support more secure ssh keys
gem 'bixby', '~> 3.0'
gem "blacklight_range_limit", '~>6'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'browse-everything'
gem 'capistrano'
gem 'capistrano-bundler', '~> 1.3'
gem 'capistrano-ext'
gem 'capistrano-rails'
gem 'citeproc-ruby'
gem 'coffee-rails', '~> 4.2'
gem 'csl-styles'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'dotenv-rails'
gem 'ed25519', '~> 1.2', '>= 1.2.4'
gem 'honeybadger', '~> 4.4.0'
gem 'hydra-file_characterization', '~> 1.1'
gem 'hydra-role-management'
gem 'hyrax', '~> 3.6'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'nokogiri', '>=1.8.2'
gem 'parser'
gem 'pg'
gem 'puma'
gem 'rails', '~> 5'
gem 'rails-assets-tether'
gem 'rainbow'
gem 'redcarpet'
gem 'redis', '~> 4.1'
gem 'redis-activesupport'
gem 'rsolr', '>= 1.0'
gem 'rubyzip', '~> 1.0', require: 'zip'
gem 'sass-rails', '~> 5.0'
gem 'sassc-rails', '>= 2.1.0'
gem 'sidekiq', '< 7'
gem 'simple_form', ">= 5.0.0"
gem 'solrizer'
gem 'strscan', '1.0.3' # match version installed on server as system gem
gem 'terser'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'whenever', require: false

group :development do
  gem 'capistrano-passenger'
  gem 'capistrano-sidekiq'
  gem 'listen'
  gem 'web-console', '~> 3.7'
  gem 'xray-rails'
  gem 'yard'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'fcrepo_wrapper'
  gem 'solr_wrapper'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'poltergeist'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'webdrivers'
end
