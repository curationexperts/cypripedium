# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "actionview", ">= 5.1.6.2"
gem 'active_job_status', '~> 1.2.1'
gem 'bagit'
gem 'bixby', '2.0.0.pre.beta1'
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
gem 'honeybadger', '~> 4.4.0'
gem 'hydra-file_characterization', '~> 1.1'
gem 'hydra-role-management'
gem 'hyrax', '2.7.0'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'nokogiri', '>=1.8.2'
gem 'parser'
gem 'pg'
gem 'puma', '~> 3.12'
gem 'rails', '~> 5.1.6'
gem 'rainbow'
gem 'redcarpet'
gem 'redis', '~> 3.0'
gem 'redis-activesupport'
gem 'rsolr', '>= 1.0'
gem 'rubyzip', '~> 1.0', require: 'zip'
gem 'sass-rails', '~> 5.0'
gem 'sassc-rails', '>= 2.1.0'
gem 'sidekiq'
gem 'simple_form', ">= 5.0.0"
gem 'sqlite3', '~> 1.3.6'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'uglifier', '>= 1.3.0'
gem 'webdrivers'
gem 'whenever', require: false

group :development do
  gem 'capistrano-passenger'
  gem 'capistrano-sidekiq', '~> 0.20.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry'
  gem 'pry-doc'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
  gem 'xray-rails'
  gem 'yard'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'solr_wrapper', '>= 0.3'
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'poltergeist'
end
