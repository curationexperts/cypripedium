# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportsController, type: :routing do
  describe 'admin routes' do
    it 'routes GET /admin/exports to #index' do
      expect(get: '/admin/exports').to route_to('exports#index')
    end

    it 'routes POST /admin/exports to #create' do
      expect(post: '/admin/exports').to route_to('exports#create')
    end

    it 'routes DELETE /admin/exports/:id to #destroy' do
      expect(delete: '/admin/exports/1').to route_to('exports#destroy', id: '1')
    end
  end

  describe 'public routes' do
    it 'routes GET /exports/downloads/:id to #download' do
      expect(get: '/exports/downloads/1').to route_to('exports#download', id: '1')
    end
  end

  describe 'does not provide' do
    it 'a route to #new' do
      expect(get: '/admin/exports/new').to route_to('pages#error_404', path: 'admin/exports/new')
    end

    it 'a route to #show' do
      expect(get: '/admin/exports/1').to route_to('pages#error_404', path: 'admin/exports/1')
    end

    it 'a route to #edit' do
      expect(get: '/admin/exports/1/edit').to route_to('pages#error_404', path: 'admin/exports/1/edit')
    end

    it 'a route to #update via PUT' do
      expect(put: '/admin/exports/1').to route_to('pages#error_404', path: 'admin/exports/1')
    end

    it 'a route to #update via PATCH' do
      expect(patch: '/admin/exports/1').to route_to('pages#error_404', path: 'admin/exports/1')
    end
  end
end
