# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Contentdm::Log do
  let(:message) { 'This is a message' }
  let(:info_level) { 'info' }
  let(:error_level) { 'error' }
  let(:debug_level) { 'debug' }
  let(:file) { StringIO.new }
  let(:info_log) { described_class.new(message, info_level, file) }
  let(:error_log) { described_class.new(message, error_level, file) }
  let(:debug_log) { described_class.new(message, debug_level, file) }
  it 'logs to stdout' do
    expect { info_log }.to output(/This is a message/).to_stdout_from_any_process
    expect { error_log }.to output(/This is a message/).to_stdout_from_any_process
    expect { debug_log }.to output(/This is a message/).to_stdout_from_any_process
  end

  it 'logs to a file' do
    info_log
    expect(file.string).to match(/This is a message/)
  end
end
