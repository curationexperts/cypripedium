# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Creator, type: :model do
  it "has a ID" do
    creator = described_class.create(display_name: "Allen, Stephen G.")
    expect(creator.id).not_to be nil
    expect(creator.display_name).to eq "Allen, Stephen G."
  end
  it "doesn't allow an empty display_name" do
    expect do
      described_class.create!
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Display name can't be blank/)
  end
  it "doesn't allow a blank display_name" do
    expect do
      described_class.create!(display_name: "")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Display name can't be blank/)
  end
  it "doesn't allow duplicate RePEc ids" do
    described_class.create(display_name: "Allen, Stephen G.", repec: "pal73")
    expect do
      described_class.create!(display_name: "Allen, Stephen Gomes", repec: "pal73")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Repec id already in the system/)
  end
  it "doesn't allow duplicate VIAF ids" do
    described_class.create(display_name: "Allen, Stephen G.", viaf: "789875")
    expect do
      described_class.create!(display_name: "Allen, Stephen Gomes", viaf: "789875")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Viaf id already in the system/)
  end
  it "has multiple alternate names" do
    creator = described_class.create(display_name: "Allen, Stephen G.", alternate_names: ["Allen, S. Gomes", "Aliens, Steve"])
    expect(creator.alternate_names.count).to eq 2
    expect(creator.alternate_names.first).to eq "Allen, S. Gomes"
  end
  context 'with an accidentally-deleted creator' do
    let(:work) {
      FactoryBot.build(:populated_publication,
      creator_id: [creator_one.authority_rdf, creator_two.authority_rdf, creator_three.authority_rdf])
    }
    let(:solr) { Blacklight.default_index.connection }
    let(:creator_one) { FactoryBot.create(:creator, display_name: 'Kehoe, Patrick J.') }
    let(:creator_two) { FactoryBot.create(:creator, display_name: 'Backus, David', alternate_names: ['Backus, Davey', 'Backus-Up, David']) }
    let(:creator_three) { FactoryBot.create(:creator, display_name: 'Kehoe, Timothy J.') }

    it "fails gracefully" do
      work.save!
      creator_one.delete
      creator_two.display_name = 'Else, Somebody'
      expect { creator_two.save! }.not_to raise_error
    end
  end
  it "accepts an active field" do
    creator = described_class.create(display_name: "Allen, Stephen G.", active_creator: false)
    expect(creator.active_creator).to eq false
  end

  it "can return its identifier as a uri" do
    allow(Rails.application.config)
      .to receive(:rdf_uri)
      .and_return('http://localhost:3000')
    creator = described_class.create(id: 27, display_name: "Allen, Stephen G.")
    expect(creator.authority_uri).to eq "http://localhost:3000/authorities/show/creator_authority/27"
  end

  it "can create the authority as an rdf triple" do
    creator = described_class.create(id: 27, display_name: "Allen, Stephen G.")
    expect(creator.authority_rdf).to be_an_instance_of ActiveTriples::Resource
  end
end
