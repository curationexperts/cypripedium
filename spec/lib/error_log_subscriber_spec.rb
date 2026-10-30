# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorLogSubscriber do
  context 'with an error severity report' do
    it 'logs at error level with the message, context payload, and exception' do
      error = StandardError.new('Disk full')
      allow(Rails.logger).to receive(:error)

      Rails.error.report(error, severity: :error, context: { export_id: 7, work_id: 'abc123' })

      expect(Rails.logger).to have_received(:error).with(
        message: 'Disk full',
        payload: { export_id: 7, work_id: 'abc123', source: 'application' },
        exception: error
      )
    end
  end

  context 'with a warning severity report' do
    it 'logs at warn level with the message, context payload, and exception' do
      error = StandardError.new('Disk full')
      allow(Rails.logger).to receive(:warn)

      Rails.error.report(error, severity: :warning, context: { export_id: 7, work_id: 'abc123' })

      expect(Rails.logger).to have_received(:warn).with(
        message: 'Disk full',
        payload: { export_id: 7, work_id: 'abc123', source: 'application' },
        exception: error
      )
    end
  end

  context 'with an info severity report' do
    it 'logs at info level with the message, context payload, and exception' do
      error = StandardError.new('Disk full')
      allow(Rails.logger).to receive(:info)

      Rails.error.report(error, severity: :info, context: { export_id: 7, work_id: 'abc123' })

      expect(Rails.logger).to have_received(:info).with(
        message: 'Disk full',
        payload: { export_id: 7, work_id: 'abc123', source: 'application' },
        exception: error
      )
    end
  end

  context 'with an unhandled report' do
    it 'does not log' do
      error = StandardError.new('Disk full')
      allow(Rails.logger).to receive(:error)

      Rails.error.report(error, handled: false, severity: :error, context: { export_id: 7, work_id: 'abc123' })

      expect(Rails.logger).not_to have_received(:error)
    end
  end
end
