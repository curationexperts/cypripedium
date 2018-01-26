# frozen_string_literal: true
require 'rails_helper'

describe Contentdm::Importer do
  let(:cdmi) { described_class.new(input_file, data_path, default_model) }
  let(:cdmi_invalid) { described_class.new(input_file_with_no_title, data_path, default_model) }
  let(:input_file) { file_fixture('ContentDM_XML_Full_Fields.xml') }
  let(:input_file_with_no_title) { file_fixture('cdm_xml_with_errors.xml') }
  let(:data_path) { Rails.root.join('spec', 'fixtures', 'files') }
  let(:default_model) { 'DataSet' }
  let(:collection_name) { ['Test Collection'] }
  let(:problem_record_file_name) { cdmi.problem_record_file_name }

  context 'processing an export file' do
    it 'can instantiate' do
      expect(cdmi).to be_instance_of(described_class)
    end
    it 'has a Nokogiri DOM document' do
      expect(cdmi.doc).to be_instance_of(Nokogiri::XML::Document)
    end
    it 'knows how many documents are in the import file' do
      expect(cdmi.document_count).to eq(1)
    end
    it 'knows which input file it will import' do
      expect(cdmi.input_file).to eq input_file
    end
    it 'can determine the collection title' do
      expect(cdmi.collection_name).to eq(['Test Collection'])
    end
    it 'has a default work type' do
      expect(cdmi.default_work_model).to eq 'DataSet'
    end
  end

  context 'processing a single record' do
    before do
      ActiveFedora::Cleaner.clean!
      @record = cdmi.records.first
    end
    it 'turns a contentdm record into a Fedora object' do
      work = cdmi.process_record(@record)
      expect(work).to be_instance_of(Publication)
    end
    it 'sets the Fedora object\'s visibility to open' do
      work = cdmi.process_record(@record)
      expect(work.visibility).to eq('open')
    end
    it 'adds the object to the collection' do
      work = cdmi.process_record(@record)
      cdmi.collection.save
      expect(cdmi.collection.members.last.id).to eq(work.id)
      expect(work.member_of_collections).to eq [cdmi.collection]
    end
  end

  context 'processing multiple records' do
    before do
      ActiveFedora::Cleaner.clean!
      AdminSet.find_or_create_default_admin_set_id
    end

    describe 'import' do
      it 'has a completed message' do
        expect { cdmi.import }.to output(/Saved work with title: Classical macroeconomic model/).to_stdout_from_any_process
      end

      it 'has an error message when something goes wrong during the import' do
        expect { cdmi_invalid.import }.to raise_error('XML is invalid')
      end
    end

    context 'when some records fail to import' do
      let(:input_file) { file_fixture('some_records.xml') }
      let(:model) { default_model.constantize }

      before do
        allow_any_instance_of(model).to receive(:title=).and_call_original

        # Use rspec mocks to make records 2 & 4 fail.
        # https://relishapp.com/rspec/rspec-mocks/v/3-7/docs/setting-constraints/matching-arguments#responding-differently-based-on-the-arguments
        allow_any_instance_of(model).to receive(:title=).with(['Record 222']).and_raise('Record 222 failed!')
        allow_any_instance_of(model).to receive(:title=).with(['Record 444']).and_raise('Record 444 failed!')
      end

      # 2 of the 4 records failed, so 2 should be successful
      it 'successfully imports some of the records' do
        expect { cdmi.import }.to change { model.count }.by(2)
      end

      it 'logs the errors for the failed records' do
        expect { cdmi.import }
          .to output(/Record 222 failed!/).to_stdout_from_any_process
      end

      it 'exports an XML with the failed records' do
        cdmi.import
        problem_record_file = File.open(Rails.root.join('log', problem_record_file_name))
        expect(problem_record_file.readlines.join).to match(/Record 222/) && match(/Record 444/)
        problem_record_file.close
      end
    end
  end

  context 'A record with no file to attach' do
    let(:input_file) { file_fixture('minimal_record.xml') }

    before do
      ActiveFedora::Cleaner.clean!
      AdminSet.find_or_create_default_admin_set_id
    end

    it 'successfully imports without logging any error messages' do
      expect(Contentdm::Log).not_to receive(:new).with(any_args, 'error')
      expect { cdmi.import }.to change { cdmi.work_model.count }.by(1)
    end
  end

  describe '#work_model' do
    subject(:model) { cdmi.work_model(model_name) }

    context 'with a valid string name for a model' do
      let(:model_name) { 'ConferenceProceeding' }
      it { is_expected.to eq ConferenceProceeding }
    end

    context 'with an invalid string' do
      let(:model_name) { 'Conference Proceeding' }

      it 'raises an error' do
        expect { model }.to raise_error('Invalid work type: Conference Proceeding')
      end
    end

    context 'with no value' do
      let(:model_name) { nil }

      it 'uses the default work model' do
        expect(model).to eq DataSet
        expect(model.to_s).to eq cdmi.default_work_model
      end
    end
  end
end
