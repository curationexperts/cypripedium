# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Corporate, type: :model do
  before do
    I18n.locale = 'en'
  end
  it "has a ID" do
    corporate = described_class.create(corporate_name: "Federal Reserve Bank: Research Division", corporate_state: "OK", corporate_city: "Dallas")
    expect(corporate.id).not_to be nil
    expect(corporate.corporate_name).to eq "Federal Reserve Bank: Research Division"
    expect(corporate.corporate_state).to eq "OK"
    expect(corporate.corporate_city).to eq "Dallas"
  end
  it "doesn't allow an empty corporate_name" do
    expect do
      described_class.create!(corporate_name: nil, corporate_state: "OK", corporate_city: "Dallas")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Corporate name can't be blank/)
  end
  it "doesn't allow a blank corporate_name" do
    expect do
      described_class.create!(corporate_name: "", corporate_state: "OK", corporate_city: "Dallas")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Corporate name can't be blank/)
  end
  it "doesn't allow an empty corporate_state" do
    expect do
      described_class.create!(corporate_name: "Federal Reserve Bank: Research Division", corporate_state: nil, corporate_city: "Dallas")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Corporate state can't be blank/)
  end
  it "doesn't allow a blank corporate_state" do
    expect do
      described_class.create!(corporate_name: "Federal Reserve Bank: Research Division", corporate_state: "", corporate_city: "Dallas")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Corporate state can't be blank/)
  end
  it "doesn't allow an empty corporate_city" do
    expect do
      described_class.create!(corporate_name: "Federal Reserve Bank: Research Division", corporate_state: "OK", corporate_city: nil)
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Corporate city can't be blank/)
  end
  it "doesn't allow a blank corporate_city" do
    expect do
      described_class.create!(corporate_name: "Federal Reserve Bank: Research Division", corporate_state: "OK", corporate_city: "")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Corporate city can't be blank/)
  end
  it "doesn't allow duplicate corporate names" do
    described_class.create(corporate_name: "Federal Reserve Bank: Research Division", corporate_state: "OK", corporate_city: "Dallas")
    expect do
      described_class.create!(corporate_name: "Federal Reserve Bank: Research Division", corporate_state: "MN", corporate_city: "San Fransisco")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Corporate name id already in the system/)
  end
  # context 'with an accidentally-deleted corporate' do
  #   let(:work) {
  #     FactoryBot.build(:populated_publication,
  #     corporate_id: [corporate_one.authority_rdf, corporate_two.authority_rdf, corporate_three.authority_rdf])
  #   }
  #   let(:solr) { Blacklight.default_index.connection }
  #   let(:corporate_one) { FactoryBot.create(:corporate, corporate_name: 'Kehoe, Patrick J.') }
  #   let(:corporate_two) { FactoryBot.create(:corporate, corporate_name: 'Backus, David', alternate_names: ['Backus, Davey', 'Backus-Up, David']) }
  #   let(:corporate_three) { FactoryBot.create(:corporate, corporate_name: 'Kehoe, Timothy J.') }

  #   it "fails gracefully" do
  #     work.save!
  #     corporate_one.delete
  #     corporate_two.corporate_name = 'Else, Somebody'
  #     expect { corporate_two.save! }.not_to raise_error
  #   end
  # end

  it "can return its identifier as a uri" do
    allow(Rails.application.config)
      .to receive(:rdf_uri)
      .and_return('http://localhost:3000')
    corporate = described_class.create(id: 27, corporate_name: "Federal Reserve Bank: Research Division", corporate_state: "OK", corporate_city: "Dallas")
    expect(corporate.authority_uri).to eq "http://localhost:3000/authorities/show/corporate_authority/27"
  end

  it "can create the authority as an rdf triple" do
    corporate = described_class.create(id: 27, corporate_name: "Federal Reserve Bank: Research Division", corporate_state: "OK", corporate_city: "Dallas")
    expect(corporate.authority_rdf).to be_an_instance_of ActiveTriples::Resource
  end
end
