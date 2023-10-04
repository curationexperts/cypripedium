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
gem "blacklight_range_limit", '~>7.0.0'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'browse-everything'
gem 'capistrano'
gem 'capistrano-bundler', '~> 1.3'
gem 'capistrano-ext'
gem 'capistrano-rails'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'dotenv-rails'
gem 'ed25519', '~> 1.2', '>= 1.2.4'
gem 'honeybadger', '~> 4.4.0'
gem 'hydra-file_characterization', '~> 1.1'
gem 'hydra-role-management'
gem 'hyrax', '~> 3.4'
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
gem 'sidekiq'
gem 'simple_form', ">= 5.0.0"
gem 'solrizer'
gem 'terser'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'whenever', require: false

group :development do
  gem 'capistrano-passenger'
  gem 'capistrano-sidekiq', '~> 0.20.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry'
  gem 'pry-doc'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '~> 3.7'
  gem 'xray-rails'
  gem 'yard'
end

group :development, :test do
  gem 'bummr'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'debase', '~> 0.2.4.1'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'ruby-debug-ide'
  gem 'solr_wrapper', '>= 0.3'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
