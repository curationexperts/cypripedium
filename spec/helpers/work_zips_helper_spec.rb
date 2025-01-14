# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkZipsHelper, type: :helper do
  describe '#display_work_zip_controls' do
    subject(:return_value) { helper.display_work_zip_controls(work_zip) }

    context 'when the zip file exists' do
      let(:work_zip) { WorkZip.new(file_path: zip_path, work_id: '123') }
      let(:zip_path) { file_fixture('test_file.zip').to_s }

      it 'returns a link to download the zip file' do
        expect(return_value).to match(/href.*\/zip\/123/)
        expect(return_value).to match(/Download the zip file/)
      end
    end

    context 'when the file path exists, but the zip file has been deleted' do
      let(:work_zip) { WorkZip.new(file_path: zip_path, work_id: '123') }
      let(:zip_path) { File.join(fixture_path, 'non_existent_file') }

      it 'returns a button to create the zip file' do
        expect(return_value).to match(/\/zip\/123/)
        expect(return_value).to match(/Create the Zip/)
      end
    end

    context 'when the job status is unavailable' do
      let(:work_zip) { WorkZip.new(work_id: '123', status: :unavailable) }

      it 'returns a button to create the zip file' do
        expect(return_value).to match(/\/zip\/123/)
        expect(return_value).to match(/Create the Zip/)
      end
    end

    context 'when the job queued' do
      let(:work_zip) { WorkZip.new(work_id: '123', status: :queued) }

      it 'returns a corresponding message' do
        expect(return_value).to match(/job is currently queued. Please check back/)
      end
    end

    context 'when the job working' do
      let(:work_zip) { WorkZip.new(work_id: '123', status: :working) }

      it 'returns a corresponding message' do
        expect(return_value).to match(/job is currently working. Please check back/)
      end
    end
  end
end
