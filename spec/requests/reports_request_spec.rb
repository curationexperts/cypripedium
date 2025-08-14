# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe "/reports", type: :request do
  let(:admin) { FactoryBot.create(:admin) }

  context 'as an administrator' do
    before do
      login_as admin
    end

    describe "GET /index" do
      it "renders a successful response" do
        get reports_path
        expect(response).to be_successful
      end
    end

    # Only the #index action should be routable, all the others should return a 404
    # We're only testing #show as a proxy for all the other actions
    describe "GET /show" do
      it "does not exist" do
        expect { get report_path(1) }.to raise_exception(NoMethodError)
        get '/report/1'
        expect(response).to be_not_found
      end
    end
  end

  context 'as a regular user' do
    logout

    describe "GET /index" do
      it "is not accessible" do
        get reports_path

        # Authorization failures currently default to redirecting to the sign-in page
        # see Hydra::Controller::ControllerBehavior#deny_access
        expect(response).to redirect_to(new_user_session_path(locale: I18n.locale))
      end
    end

    describe "GET /show" do
      # all other actions should return a 404 error
      it "does not exist" do
        expect { get report_path(1) }.to raise_exception(NoMethodError)
        get '/report/1'
        expect(response).to be_not_found
      end
    end
  end
end
