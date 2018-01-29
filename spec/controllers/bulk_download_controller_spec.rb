# frozen_string_literal: true
require 'rails_helper'
describe BulkDownloadController do
  let(:work) { FactoryBot.create(:publication) }
  describe 'GET #download' do
    it 'provides a download' do
      get :download, params: { id: work.id }
      expect(response.content_type.to_s).to match(/zip/)
    end
  end
end
