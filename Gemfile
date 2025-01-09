# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.4'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'bagit'
gem 'bcrypt_pbkdf', '~> 1.1' # Needed to support more secure ssh keys
gem 'bixby', '~> 3.0'
gem "blacklight_range_limit", '~> 7.0'
# gem 'bootstrap-sass', '~> 3.4.1'
# gem 'browse-everything'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 4.0'
gem 'capistrano'
gem 'capistrano-bundler' #, '~> 1.3'
gem 'capistrano-ext'
gem 'capistrano-rails'
gem 'citeproc-ruby'
gem 'coffee-rails', '~> 4.2'
gem 'csl-styles'
gem 'dalli'
gem 'devise'
gem 'devise-guests', '~> 0.8'
gem 'dotenv-rails'
gem 'ed25519', '~> 1.2', '>= 1.2.4'
gem 'google-protobuf', '~> 3.24.4'
gem 'grpc', '~> 1.59.3'
gem 'honeybadger'
# gem 'hydra-file_characterization', '~> 1.1'
gem 'hydra-role-management'
gem 'hyrax', '~> 5.0'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
# gem 'nokogiri', '>=1.8.2'
gem 'parser'
gem 'pg', '~> 1.3'
gem 'puma'
gem 'rails', '~> 6.1'
# gem 'rails-assets-tether'
# gem 'rainbow'
gem 'redcarpet'
# gem 'redis', '~> 4.1'
# gem 'redis-activesupport'
gem 'riiif', '~> 2.1'
gem 'rsolr', '>= 1.0', '< 3'
gem 'rubyzip', '~> 1.0', require: 'zip'
gem 'sass-rails', '~> 6.0'
gem 'sassc-rails', '>= 2.1.0'
gem 'sidekiq', '~> 6.4'
# gem 'simple_form', ">= 5.0.0"
gem 'solrizer'
gem 'strscan', '1.0.3' # match version installed on server as system gem
gem 'terser'
gem 'tether-rails'
gem 'turbolinks', '~> 5'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'whenever', require: false
gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'capistrano-passenger'
  gem 'capistrano-sidekiq'
  gem 'listen'
  gem 'web-console', '~> 3.7'
  # gem 'xray-rails'
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
  gem 'faker'
  gem 'poltergeist'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'webdrivers'
end
