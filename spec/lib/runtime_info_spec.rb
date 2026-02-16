# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RuntimeInfo do
  describe '.environment' do
    before do
      # clear any memoized data
      described_class.instance_variable_set(:@environment, nil)
      described_class.instance_variable_set(:@aws_info, nil)
    end

    describe 'in production environments' do
      let(:response) { nil }

      before do
        # stub an EC2Metadata object
        metadata_service = instance_double(Aws::EC2Metadata)
        # stub the metadata service
        allow(Aws::EC2Metadata).to receive(:new).and_return(metadata_service)
        # stub metadata responses
        allow(metadata_service).to receive(:get).and_return(response)
      end

      context 'with tag:Environment=prod' do
        let(:response) { 'prod' }
        it 'returns "Production"' do
          expect(described_class.environment).to eq('EC2:Production')
        end
      end

      context 'with tag:Environment=stage' do
        let(:response) { 'stage' }
        it 'returns "Staging"' do
          expect(described_class.environment).to eq('staging')
        end
      end

      context 'with tag:Environment=qa' do
        let(:response) { 'qa' }
        it 'returns "quality assurance"' do
          expect(described_class.environment).to eq('quality assurance')
        end
      end

      context 'with tag:Environment=any other string' do
        let(:response) { 'any_other_string' }
        it 'returns the tag' do
          expect(described_class.environment).to eq('any_other_string')
        end
      end

      context 'with no Environment tag' do
        let(:response) { nil }
        it 'returns the Rails environment' do
          expect(described_class.environment).to eq('test')
        end
      end
    end

    describe 'in local environments' do
      before do
        allow(Rails).to receive(:env).and_return('test')

        # stub an EC2Metadata object
        metadata_service = instance_double(Aws::EC2Metadata)
        # stub the metadata service
        allow(Aws::EC2Metadata).to receive(:new).and_return(metadata_service)
        # speed up failures
        allow(metadata_service).to receive(:get).and_raise(Errno::EHOSTDOWN)
      end

      context 'in test' do
        it 'returns the Rails environment' do
          expect(described_class.environment).to eq('test')
        end
      end

      context 'in development' do
        before do
          allow(Rails).to receive(:env).and_return('development')
        end

        it 'returns the Rails environment' do
          expect(described_class.environment).to eq('development')
        end
      end
    end

    describe '.badge' do
      before do
        described_class.instance_variable_set(:@badge, nil)
      end

      context 'in EC2 production environments' do
        before do
          described_class.instance_variable_set(:@environment, 'EC2:Production')
        end

        it 'returns an empty string' do
          expect(described_class.badge).to eq('')
        end
      end

      context 'in other environments' do
        before do
          described_class.instance_variable_set(:@environment, 'local_test')
        end

        it 'returns a div tag with the expected ID' do
          expect(described_class.badge).to match('<div id="environment_badge">')
        end

        it 'capitalizes the envioronment name' do
          expect(described_class.badge).to match('Local Test')
        end
      end
    end
  end
end
