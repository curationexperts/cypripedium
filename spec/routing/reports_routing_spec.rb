# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ReportsController, type: :routing do
  it 'routes to #index' do
    expect(get: '/reports').to route_to('reports#index')
  end

  # Only the index view is supported, other routes should give a 404 error
  describe 'does not provide' do
    it 'routes to #new' do
      expect(get: '/reports/new').to route_to(controller: 'pages', action: 'error_404', path: 'reports/new')
    end

    it 'routes to #create' do
      expect(post: '/reports').to route_to('pages#error_404', path: 'reports')
    end

    it 'routes to #show' do
      expect(get: '/reports/1').to route_to('pages#error_404', path: 'reports/1')
    end

    it 'routes to #edit' do
      expect(get: '/reports/1/edit').to route_to('pages#error_404', path: 'reports/1/edit')
    end

    it 'routes to #update via PUT' do
      expect(put: '/reports/1').to route_to('pages#error_404', path: 'reports/1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/reports/1').to route_to('pages#error_404', path: 'reports/1')
    end

    it 'routes to #destroy' do
      expect(delete: '/reports/1').to route_to('pages#error_404', path: 'reports/1')
    end
  end
end
