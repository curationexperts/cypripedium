require 'rails_helper'

RSpec.describe WorkZipsController, type: :controller do
  let(:zip) { file_fixture('test_file.zip') }
  let(:work_id) { '123' }
  let(:xmas) { Date.new(2017, 12, 25) }

  let(:work_zip) { WorkZip.create(work_id: work_id, file_path: zip) }
  let(:older_work_zip) { WorkZip.create(work_id: work_id, file_path: zip, updated_at: xmas) }

  describe 'GET download' do
    context 'with no errors' do
      before do
        # Create the WorkZip records
        [work_zip, older_work_zip]
      end

      it 'successfully downloads a zip file' do
        expect(WorkZip.count).to eq 2
        get :download, params: { work_id: work_id }
        expect(response.content_type.to_s).to match(/zip/)
        expect(response.header['Content-Disposition']).to include('test_file.zip')
      end
    end

    context 'when it fails to find the zip' do
      it 'returns not found status' do
        expect(WorkZip.count).to eq 0
        expect {
          get :download, params: { work_id: work_id }
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
