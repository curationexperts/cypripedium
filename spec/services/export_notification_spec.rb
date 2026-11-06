# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ExportNotification do
  let(:export) { FactoryBot.build(:export) }
  let(:notification) { described_class.new(export) }
  let(:parsed_message) { Capybara.string(notification.message) }

  describe '#subject' do
    context 'for completed exports' do
      let(:export) { FactoryBot.build(:export, id: 37, status: :completed) }
      it 'lists the id and status' do
        expect(notification.subject).to eq "Export 37 completed"
      end
    end

    context 'for failed exports' do
      let(:export) { FactoryBot.build(:export, id: 37, status: :failed) }
      it 'lists the id and status' do
        expect(notification.subject).to eq "Export 37 failed"
      end
    end

    context 'for other statuses' do
      let(:export) { FactoryBot.build(:export, status: :working) }
      it 'does nothing' do
        expect(notification.subject).to be_nil
      end
    end
  end

  describe '#message' do
    context 'for completed exports' do
      let(:export) { FactoryBot.build(:export, id: 37, status: :completed) }
      it 'lists the id and status' do
        expect(parsed_message.text.squish).to start_with "Export 37 completed."
      end
    end

    context 'for failed exports' do
      let(:export) { FactoryBot.build(:export, id: 37, status: :failed) }
      it 'lists the id and status' do
        expect(parsed_message.text.squish).to start_with "Export 37 failed."
      end
    end

    context 'for package-level failures' do
      let(:export) { FactoryBot.build(:export, status: :failed, message: 'No space left on device') }
      let(:exception_text) { parsed_message.find('.exception').text.squish }
      it 'includes the error message' do
        expect(exception_text).to eq 'The error message was: "No space left on device".'
      end
    end

    context 'without package-level failures' do
      let(:export) { FactoryBot.build(:export, status: :failed, message: nil) }
      it 'does not include any error message' do
        expect(parsed_message).not_to have_css('.exception')
      end
    end

    context 'for exports with archive files' do
      let(:export) do
        FactoryBot.build(:export, id: 37, status: :completed).tap do |export|
          export.export_file.attach(io: StringIO.new('zip'), filename: 'my_export.zip', content_type: 'application/zip')
        end
      end
      let(:download_span) { parsed_message.find('.download') }
      it 'includes a download link' do
        expect(download_span).to have_link('my_export.zip', href: '/exports/downloads/37')
      end

      it 'does not include any error counts' do
        expect(parsed_message).not_to have_css('.csv-errors')
      end

      context 'with errors' do
        let(:export) do
          FactoryBot.build(:export, id: 37, status: :completed, error_count: 3).tap do |export|
            export.export_file.attach(io: StringIO.new('zip'), filename: 'my_export.zip', content_type: 'application/zip')
          end
        end
        let(:error_text) { parsed_message.find('.csv-errors').text.squish }
        it 'includes an error count' do
          expect(error_text).to eq '3 errors are listed in the "metadata.csv" file in the archive.'
        end
      end

      context 'with a single error' do
        let(:export) do
          FactoryBot.build(:export, id: 37, status: :completed, error_count: 1).tap do |export|
            export.export_file.attach(io: StringIO.new('zip'), filename: 'my_export.zip', content_type: 'application/zip')
          end
        end
        let(:error_text) { parsed_message.find('.csv-errors').text.squish }
        it 'uses the single case and verb' do
          expect(error_text).to eq '1 error is listed in the "metadata.csv" file in the archive.'
        end
      end
    end

    context 'for exports without archive files' do
      let(:export) do
        FactoryBot.build(:export, status: :failed)
      end
      it 'does not include any download link' do
        expect(parsed_message).not_to have_css('.download')
      end

      it 'does not include any error counts' do
        expect(parsed_message).not_to have_css('.csv-errors')
      end
    end

    context 'status summary' do
      let(:summary_text) { parsed_message.find('.summary').text.squish }

      context 'for exports without an exported_count' do
        let(:export) { FactoryBot.build(:export, status: :completed, items: ['one', 'two'], exported_count: nil) }
        it 'is omitted' do
          expect(parsed_message).not_to have_css('.summary')
        end
      end

      context 'for successful exports' do
        let(:export) { FactoryBot.build(:export, status: :completed, items: ['one', 'two'], exported_count: 2, error_count: 0) }
        it 'gives a success message' do
          expect(summary_text).to eq 'All items were exported successfully.'
        end
      end

      context 'for failed exports with errors' do
        let(:export) { FactoryBot.build(:export, status: :completed, items: ['one', 'two'], exported_count: 2, error_count: 1000) }
        it 'gives a message without the "successfully" suffix' do
          expect(summary_text).to eq 'All items were exported.'
        end
      end

      context 'when some items are omitted due to visibility' do
        let(:export) { FactoryBot.build(:export, status: :completed, items: ['one', 'two'], exported_count: 1, error_count: 0) }
        it 'flags filtering' do
          expect(summary_text).to eq 'Due to visibility restrictions, some items were not exported.'
        end
      end

      context 'when all items are omitted due to visibility' do
        let(:export) { FactoryBot.build(:export, status: :completed, items: ['one', 'two'], exported_count: 0, error_count: 0) }
        it 'flags filtering' do
          expect(summary_text).to eq 'Due to visibility restrictions, no items were exported.'
        end
      end

      context 'when some items are omitted' do
        let(:export) { FactoryBot.build(:export, status: :completed, items: ['one', 'two'], exported_count: 1, error_count: 3) }
        it 'flags filtering' do
          expect(summary_text).to eq 'Due to visibility restrictions or errors, some items were not exported.'
        end
      end

      context 'when all items are omitted' do
        let(:export) { FactoryBot.build(:export, status: :completed, items: ['one', 'two'], exported_count: 0, error_count: 3) }
        it 'flags filtering' do
          expect(summary_text).to eq 'Due to visibility restrictions or errors, no items were exported.'
        end
      end
    end

    context 'for other statuses' do
      let(:export) { FactoryBot.build(:export, id: 3, status: :working) }
      it 'does nothing' do
        expect(notification.message).to be_nil
      end
    end
  end
end
