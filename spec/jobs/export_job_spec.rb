# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportJob, type: :job do
  let(:admin) { FactoryBot.create(:admin) }
  let(:guest) { FactoryBot.create(:guest) }
  let(:system_user) { FactoryBot.create(:admin, email: Hyrax.config.system_user_key) }
  let(:exported_count) { 1 }
  let(:error_count) { 0 }

  let(:export) { FactoryBot.create(:export, user: admin) }

  before do
    allow(User).to receive(:system_user).and_return(system_user)
    allow(system_user).to receive(:send_message)
    allow(ExportPackager).to receive(:package_items) do |packaged_export|
      packaged_export.export_file.attach(io: StringIO.new('zip'), filename: 'my_export.zip', content_type: 'application/zip')
      packaged_export.update!(exported_count: exported_count, error_count: error_count)
    end
    allow(Rails.error).to receive(:report)
  end

  describe 'status lifecycle' do
    it 'sets status to :queued when queued', :aggregate_failures do
      expect(export.status).to eq 'unknown'
      described_class.perform_later(export)
      expect(export.reload.status).to eq 'queued'
    end

    it 'sets status to :working while packaging' do
      status_while_packaging = nil
      allow(ExportPackager).to receive(:package_items) { |packaged_export| status_while_packaging = packaged_export.status }
      described_class.perform_now(export)
      expect(status_while_packaging).to eq 'working'
    end

    it 'sets status to :completed on success with no errors', :aggregate_failures do
      described_class.perform_now(export)
      expect(export.reload.status).to eq 'completed'
    end

    context 'with work or file errors' do
      let(:error_count) { 1 }
      it 'sets status to :completed without raising an exception', :aggregate_failures do
        expect { described_class.perform_now(export) }.not_to raise_error
        expect(export.reload.status).to eq 'completed'
      end
    end

    it 'sets status to :failed when an exception occurs', :aggregate_failures do
      # Stub Packaging error
      allow(ExportPackager).to receive(:package_items).and_raise(StandardError, 'Packaging failed')
      expect { described_class.perform_now(export) }.to raise_error(StandardError)
      expect(export.reload.status).to eq 'failed'
    end
  end

  describe 'exception handling' do
    let(:export) { FactoryBot.create(:export, id: 4321) }
    before do
      # Stub Packaging error
      allow(ExportPackager).to receive(:package_items).and_raise(StandardError, 'Packaging failed')
    end

    it 'raises the error' do
      expect { described_class.perform_now(export) }.to raise_error(StandardError, 'Packaging failed')
    end

    it 'reports the error with the export id' do
      expect { described_class.perform_now(export) }.to raise_error(StandardError)
      expect(Rails.error).to have_received(:report).with(
        an_instance_of(StandardError).and(having_attributes(message: 'Packaging failed')),
        severity: :error,
        context: { export_id: 4321 }
      )
    end

    it 'saves the first line of the exception message', :aggregate_failures do
      allow(ExportPackager).to receive(:package_items).and_raise(StandardError, "Disk full\nat line 3")
      expect { described_class.perform_now(export) }.to raise_error(StandardError)
      expect(export.reload.message).to eq 'Disk full'
    end

    it 'disables Sidekiq retries' do
      expect(described_class.sidekiq_options['retry']).to be false
    end
  end

  describe 'user notification' do
    let(:export) { FactoryBot.create(:export, id: 4321, user: admin) }

    context 'for admins' do
      it 'sends a message on completion', :aggregate_failures do
        described_class.perform_now(export)
        expect(system_user).to have_received(:send_message) do |recipient, body, subject|
          expect(recipient).to eq admin
          expect(subject).to eq 'Export 4321 completed'
          expect(Capybara.string(body).text.squish)
            .to eq 'Export 4321 completed. 1 item was exported successfully. ' \
                   'The exported archive can be downloaded at my_export.zip.'
        end
      end

      it 'sends a message on failure', :aggregate_failures do
        allow(ExportPackager).to receive(:package_items).and_raise(StandardError, 'Packaging failed')
        expect { described_class.perform_now(export) }.to raise_error(StandardError)
        expect(system_user).to have_received(:send_message) do |recipient, body, subject|
          expect(recipient).to eq admin
          expect(subject).to eq 'Export 4321 failed'
          expect(Capybara.string(body).text.squish)
            .to eq 'Export 4321 failed. The error message was: "Packaging failed".'
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
        expect { described_class.perform_now(export) }.to raise_error(StandardError)
      end
    end
  end
end
