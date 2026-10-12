# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportJob, type: :job do
  let(:admin) { FactoryBot.create(:admin) }
  let(:guest) { FactoryBot.create(:guest) }
  let(:system_user) { FactoryBot.create(:admin, email: Hyrax.config.system_user_key) }

  let(:export) { FactoryBot.create(:export, user: admin) }

  before do
    allow(User).to receive(:system_user).and_return(system_user)
    allow(ExportPackager).to receive(:package_items).and_return(7)
  end

  describe 'status lifecycle' do
    it 'sets status to :queued when queued', :aggregate_failures do
      expect(export.status).to eq 'unknown'
      described_class.perform_later(export)
      expect(export.reload.status).to eq 'queued'
    end

    it 'sets status to :completed on success', :aggregate_failures do
      expect(export).to receive(:working!)
      described_class.perform_now(export)
      expect(export.reload.status).to eq 'completed'
    end

    it 'sets status to :failed with an error message when an exception occurs', :aggregate_failures do
      # Stub Packaging error
      allow(ExportPackager).to receive(:package_items).and_raise(StandardError, 'Packaging failed')
      described_class.perform_now(export)
      expect(export.reload.status).to eq 'failed'
      expect(export.reload.message).to eq 'Packaging failed'
    end
  end

  describe 'user notification' do
    context 'for admins' do
      it 'sends a success message on completion' do
        expect(system_user).to receive(:send_message).with(
          admin,                                    # to:
          a_string_matching(/containing 7 items/i), # body
          a_string_matching(/completed/i)           # subject
        )
        described_class.perform_now(export)
      end

      it 'sends a failure message on error' do
        allow(ExportPackager).to receive(:package_items).and_raise(StandardError, 'Packaging failed')

        expect(system_user).to receive(:send_message).with(
          admin,                                 # to:
          a_string_matching(/Packaging failed/), # body
          a_string_matching(/failed/i)           # subject
        )
        described_class.perform_now(export)
      end

      it 'includes a link to the export file' do
        export.update!(filename: 'my_export')
        allow(system_user).to receive(:send_message)

        described_class.perform_now(export)

        expect(system_user).to have_received(:send_message) do |_recipient, body, _subject|
          link = Nokogiri::HTML.fragment(body).at_css('a')
          expect(link['href']).to eq "/exports/downloads/#{export.id}"
          expect(link.text.strip).to eq 'my_export.zip'
        end
      end
    end

    context 'for guests' do
      let(:export) { FactoryBot.create(:export, user: guest) }

      it 'sends no success messages' do
        expect(system_user).not_to receive(:send_message)
        described_class.perform_now(export)
      end

      it 'sends no failure messages' do
        allow(ExportPackager).to receive(:package_items).and_raise(StandardError, 'Packaging failed')

        expect(system_user).not_to receive(:send_message)
        described_class.perform_now(export)
      end
    end
  end
end
