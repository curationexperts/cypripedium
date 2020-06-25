# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildWorkZipJob, type: :job do
  let(:publication) { create(:publication, title: ['My Publication']) }
  let(:work_zip) { WorkZip.create(work_id: publication.id) }

  context 'running the job' do
    it 'calls the method to create the zip file' do
      allow(WorkZip).to receive(:find).with(work_zip.id).and_return(work_zip)
      expect(work_zip).to receive(:create_zip)
      described_class.perform_now(work_zip.id)
    end
  end
end
