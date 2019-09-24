# frozen_string_literal: true

set :stage, :cyp18
set :rails_env, 'production'
server 'cyp18.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
append :linked_files, ".env.production"
