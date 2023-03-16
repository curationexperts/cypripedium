# frozen_string_literal: true

Rails.application.routes.draw do
  get '/users/signup', to: 'pages#error_404'
  post '/users', to: 'pages#error_404'
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  resources :creators
  mount BrowseEverything::Engine => '/browse'
  root 'homepage#index'
  mount Blacklight::Engine => '/'

  # Mount sidekiq web ui and require authentication by an admin user
  require 'sidekiq/web'
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'

  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resource :user_collection, only: [:create, :destroy, :show]
  resources :user_collections, only: [:index, :edit, :show]

  get  '/zip/:work_id', to: 'work_zips#download', as: 'download_zip'
  post '/zip/:work_id', to: 'work_zips#create', as: 'create_zip'
  get '/bag/:file_name', to: 'bag#download'
  post '/bag/create', to: 'bag#create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'error_404', to: 'pages#error_404'
  # If you go somewhere without a route, show a 404 page
  match '*path', via: :all, to: 'pages#error_404'
end
