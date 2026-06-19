# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/exports', type: :request do
  let(:admin) { FactoryBot.create(:admin) }
  let(:user)  { FactoryBot.create(:user) }
  let!(:export) { FactoryBot.create(:export) }

  describe 'GET /admin/exports' do
    context 'as an administrator' do
      before { sign_in admin }

      it 'includes the export in the response', :aggregate_failures do
        get exports_path
        expect(response).to be_successful
        expect(response.body).to include(export.id.to_s)
      end
    end

    context 'as a regular user' do
      before { sign_in user }

      it 'returns not found' do
        get exports_path
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not logged in' do
      it 'returns not found' do
        get exports_path
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /admin/exports/:id' do
    context 'as an administrator' do
      before { sign_in admin }

      it 'destroys the export record' do
        expect {
          delete export_path(export)
        }.to change(Export, :count).by(-1)
      end

      it 'redirects to the index' do
        delete export_path(export)
        expect(response).to redirect_to(exports_path(locale: I18n.locale))
      end
    end

    context 'as a regular user' do
      before { sign_in user }

      it 'returns not found' do
        delete export_path(export)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not logged in' do
      it 'returns not found' do
        delete export_path(export)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /exports/downloads/:id' do
    let(:attached_zip) { FactoryBot.create(:export, format: :zip) }
    let(:attached_bag) { FactoryBot.create(:export, format: :bag) }

    def attach_file(export)
      file = fixture_file_upload('test_file.zip', 'application/zip')
      export.export_file.attach(file)
    end

    context 'for a zip export' do
      before { attach_file(attached_zip) }

      context 'as an administrator' do
        before { sign_in admin }

        it 'redirects to the download' do
          get export_download_path(attached_zip)
          expect(response).to redirect_to(/active_storage\/blobs/)
        end
      end

      context 'as a regular user' do
        before { sign_in user }

        it 'redirects to the download' do
          get export_download_path(attached_zip)
          expect(response).to redirect_to(/active_storage\/blobs/)
        end
      end

      context 'when not logged in' do
        it 'redirects to the download' do
          get export_download_path(attached_zip)
          expect(response).to redirect_to(/active_storage\/blobs/)
        end
      end
    end

    context 'for a bag export' do
      before { attach_file(attached_bag) }

      context 'as an administrator' do
        before { sign_in admin }

        it 'redirects to the download' do
          get export_download_path(attached_bag)
          expect(response).to redirect_to(/active_storage\/blobs/)
        end
      end

      context 'as a regular user' do
        before { sign_in user }

        it 'returns not found' do
          get export_download_path(attached_bag)
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when not logged in' do
        it 'returns not found' do
          get export_download_path(attached_bag)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the export has no attached file' do
      before { sign_in admin }

      it 'returns not found' do
        get export_download_path(export)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the export does not exist' do
      it 'returns not found' do
        get export_download_path(id: 'nonexistent')
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /admin/exports' do
    let(:items) { ['abc123', 'def456'] }

    context 'as an administrator' do
      before { sign_in admin }

      it 'creates an Export record' do
        expect {
          post exports_path, params: { export: { items: items } }
        }.to change(Export, :count).by(1)
      end

      it 'sets the correct attributes on the export', :aggregate_failures do
        post exports_path, params: { export: { items: items } }
        export = Export.last
        expect(export.items).to eq items
        expect(export.format).to eq 'bag'
        expect(export.user).to eq admin
      end

      it 'enqueues an ExportJob' do
        expect {
          post exports_path, params: { export: { items: items } }
        }.to have_enqueued_job(ExportJob)
      end

      it 'redirects to the exports index' do
        post exports_path, params: { export: { items: items } }
        expect(response).to redirect_to(exports_path(locale: I18n.locale))
      end

      it 'sets a notice flash message' do
        post exports_path, params: { export: { items: items } }
        expect(flash[:notice]).to be_present
      end

      context 'when no items are selected' do
        it 'does not create an Export record' do
          expect {
            post exports_path, params: { export: { items: [] } }
          }.not_to change(Export, :count)
        end

        it 'redirects back with an alert' do
          post exports_path, params: { export: { items: [] } },
                             headers: { 'HTTP_REFERER' => hyrax.dashboard_works_path(locale: :en) }
          expect(response).to redirect_to(hyrax.dashboard_works_path(locale: :en))
          expect(flash[:alert]).to be_present
        end
      end
    end

    context 'as a regular user' do
      before { sign_in user }

      it 'returns not found' do
        post exports_path, params: { export: { items: items } }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not logged in' do
      it 'returns not found' do
        post exports_path, params: { export: { items: items } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
