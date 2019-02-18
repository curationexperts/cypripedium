# frozen_string_literal: true

RSpec.shared_examples 'a work presenter' do
  describe '#work_zip' do
    subject(:work_zip) { presenter.work_zip }

    context 'when the work has an associated WorkZip record' do
      let!(:wz) { WorkZip.create(work_id: presenter.id) }
      let!(:older_wz) { WorkZip.create(work_id: presenter.id, updated_at: xmas) }
      let(:xmas) { Date.new(2017, 12, 25) }

      it { is_expected.to eq wz }
    end

    context 'when there are no WorkZip records for this work' do
      it 'builds a new WorkZip' do
        expect(work_zip.new_record?).to eq true
        expect(work_zip).to be_instance_of WorkZip
        expect(work_zip.work_id).to eq presenter.id
      end
    end
  end
end
