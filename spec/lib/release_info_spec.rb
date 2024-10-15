# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReleaseInfo do
  let(:tail) { 'branch v5.7.0 (at 421a8aba9fd81ad3921bb7af9a15a88dc1cf0bae) deployed as release 20240815215958 by mark' }

  before do
    # clear any memoized data
    described_class.instance_variable_set(:@sha, nil)
    described_class.instance_variable_set(:@branch, nil)
    described_class.instance_variable_set(:@deployment_timestamp, nil)
  end

  describe 'in production environments' do
    before do
      # stub running in a Capistrano deployment environment
      allow(described_class).to receive(:capistrano?).and_return(true)
      # stub Capistrano revision log
      allow(described_class).to receive(:`).with(/tail/).and_return(tail)
    end

    it 'returns the branch' do
      expect(described_class.branch).to eq 'v5.7.0'
    end

    it 'returns the commit' do
      expect(described_class.sha).to eq '421a8aba9fd81ad3921bb7af9a15a88dc1cf0bae'
    end

    it 'returns the deployment date' do
      expect(described_class.deployment_timestamp).to eq '15 August 2024'
    end
  end

  describe 'in development or test environments' do
    before do
      allow(described_class).to receive(:`).with(/git rev-parse HEAD/).and_return('commit_sha')
      allow(described_class).to receive(:`).with(/git rev-parse --abbrev-ref HEAD/).and_return('branch_name')
    end

    it 'returns the branch' do
      expect(described_class.branch).to eq 'branch_name'
    end

    it 'returns the commit' do
      expect(described_class.sha).to eq 'commit_sha'
    end

    it 'returns the deployment date' do
      expect(described_class.deployment_timestamp).to eq 'Not in deployed environment'
    end
  end

  describe 'in unidentifiable environments' do
    let(:env) { ActiveSupport::StringInquirer.new('undefined_environment') }

    before do
      allow(Rails).to receive(:env).and_return(env)
      described_class.instance_variable_set(:@dev_test, nil)
    end

    it 'returns the branch' do
      expect(described_class.branch).to eq 'Unknown branch'
    end

    it 'returns the commit' do
      expect(described_class.sha).to eq 'Unknown SHA'
    end

    it 'returns the deployment date' do
      expect(described_class.deployment_timestamp).to eq 'Not in deployed environment'
    end
  end
end
