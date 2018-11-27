require 'rails_helper'
require 'fileutils'

RSpec.describe BagController, type: :controller do
  let(:bag_path) { Rails.application.config.bag_path }
  let(:bag_file_path) { [Rails.application.config.bag_path, '/test.zip'].join }
  let(:user) { FactoryBot.create(:admin) }

  before do
    FileUtils.mkdir(bag_path)
    FileUtils.touch(bag_file_path)
  end

  after do
    FileUtils.rm_rf(bag_path)
  end

  describe "GET #download" do
    it "returns http success" do
      get :download, params: { file_name: 'test' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "redirects after the request" do
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)

      post :create, params: { work_ids: ['ids1'] }
      expect(response).to have_http_status(302)
    end
  end
end
