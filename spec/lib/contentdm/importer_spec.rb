require 'rails_helper'

describe Contentdm::Importer do
  let(:cdmi) { described_class.new }
  context "processing an export file" do
    it "can instantiate" do
      expect(cdmi).to be_instance_of(described_class)
    end
    it "has a Nokogiri DOM document" do
      expect(cdmi.doc).to be_instance_of(Nokogiri::XML::Document)
    end
    it "knows how many documents are in the import file" do
      expect(cdmi.document_count).to eq(79)
    end
  end
  context "processing a single record" do
    before do
      @record = cdmi.records.first
    end
    it "turns a contentdm record into a Fedora object" do
      work = cdmi.process_record(@record)
      expect(work).to be_instance_of(Publication)
    end
    it "sets the Fedora object's visibility to open" do
      work = cdmi.process_record(@record)
      expect(work.visibility).to eq('open')
    end
  end
end
