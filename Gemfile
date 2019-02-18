source 'https://rubygems.org'

ruby '2.4.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'active_job_status', '~> 1.2.1'
gem 'bagit'
gem 'bixby', '2.0.0.pre.beta1'
gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
gem 'capistrano'
gem 'capistrano-bundler', '~> 1.3'
gem 'capistrano-ext'
gem 'capistrano-rails'
gem 'dotenv-rails'
gem 'honeybadger', '~> 3.1'
gem 'hydra-role-management'
gem 'nokogiri', '>=1.8.2'
gem 'parser'
gem 'pg'
gem 'redis-activesupport'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
gem 'sidekiq'
# Use sqlite3 as the database for Active Record
gem 'simple_form', '= 3.5.0'
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.7'
gem 'rainbow'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  gem 'capistrano-passenger'
  gem 'capistrano-sidekiq', '~> 0.20.0'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'pry'
  gem 'pry-doc'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'xray-rails'
  gem 'yard'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'hyrax', '2.4.1'
gem 'redcarpet'
gem 'rubyzip', require: 'zip'

group :development, :test do
  gem 'solr_wrapper', '>= 0.3'
end

gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'jquery-rails'
gem 'rsolr', '>= 1.0'
gem 'whenever', require: false

group :development, :test do
  gem 'chromedriver-helper'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
end
group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'poltergeist'
end
