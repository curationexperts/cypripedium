require 'rails_helper'

describe ContentdmImporter do
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
    # Expect these methods to return arrays
    it "gets the title(s)" do
      t = cdmi.titles(@record)
      expect(t).to be_instance_of(Array)
      expect(t).to contain_exactly("Classical macroeconomic model for the United States, a / Thomas J. Sargent.")
    end
    it "gets the creator(s)" do
      c = cdmi.creators(@record)
      expect(c).to be_instance_of(Array)
      expect(c).to contain_exactly("Sargent, Thomas J.")
    end
  end
end
