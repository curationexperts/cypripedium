# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Creator, type: :model do
  it "has a ID" do
    creator = described_class.create!(display_name: "Allen, Stephen G.")
    expect(creator.id).not_to be nil
    expect(creator.display_name).to eq "Allen, Stephen G."
  end
  it "requires a display_name" do
    creator = described_class.new
    expect(creator).to be_invalid
    expect(creator.errors[:display_name]).to include "can't be blank"
  end
  it "requires a non-blank display name" do
    creator = described_class.new(display_name: "")
    expect(creator).to be_invalid
    expect(creator.errors[:display_name]).to include "can't be blank"
  end

  describe "#group" do
    it "defaults to 'unassigned'" do
      creator = described_class.new(display_name: Faker.name)
      expect(creator.group).to eq "unassigned"
    end

    it "has predefined enum values" do
      expect(described_class.groups).to include "staff", "consultant"
    end

    it "accepts valid values" do
      creator = FactoryBot.build(:creator)
      creator.group = 'staff'
      expect(creator).to be_valid
    end

    it "rejects invalid values" do
      creator = FactoryBot.build(:creator)
      expect {
        creator.group = 'chaotic-good'
      }.to raise_error(ArgumentError, /'chaotic-good' is not a valid group/)
    end
  end

  it "doesn't allow duplicate RePEc ids" do
    described_class.create!(display_name: "Allen, Stephen G.", repec: "pal73")
    duplicate_repec = described_class.new(display_name: "Allen, Stephen Gomes", repec: "pal73")
    expect(duplicate_repec).to be_invalid
    expect(duplicate_repec.errors[:repec]).to include "id already in the system"
  end
  it "doesn't allow duplicate VIAF ids" do
    described_class.create!(display_name: "Allen, Stephen G.", viaf: "789875")
    duplicate_viaf = described_class.new(display_name: "Allen, Stephen Gomes", viaf: "789875")
    expect(duplicate_viaf).to be_invalid
    expect(duplicate_viaf.errors[:viaf]).to include "id already in the system"
  end
  it "has multiple alternate names" do
    creator = described_class.new(display_name: "Allen, Stephen G.", alternate_names: ["Allen, S. Gomes", "Aliens, Steve"])
    expect(creator.alternate_names.count).to eq 2
    expect(creator.alternate_names.first).to eq "Allen, S. Gomes"
  end

  context 'with an accidentally-deleted creator' do
    pending '- we should not be able to delete creators of existing works'
    let(:work) {
      FactoryBot.create(:publication,
                        creator: [creator_one.display_name, creator_two.display_name],
                        creator_id: [creator_one.id, creator_two.id])
    }
    let(:creator_one) { FactoryBot.create(:creator, display_name: 'Kehoe, Patrick J.') }
    let(:creator_two) { FactoryBot.create(:creator, display_name: 'Backus, David', alternate_names: ['Backus, Davey', 'Backus-Up, David']) }

    before do
      # skip background work re-indexing when we change creators
      allow(CreatorReindexJob).to receive(:perform_later)
    end

    it "fails gracefully" do
      creator_one.delete
      creator_two.display_name = 'Else, Somebody'
      creator_two.save!
      # expect { work.save! }.not_to raise_error
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
    creator = described_class.new(id: 27, display_name: "Allen, Stephen G.")
    expect(creator.authority_uri).to eq "http://localhost:3000/authorities/show/creator_authority/27"
  end

  it "can create the authority as an rdf triple" do
    creator = described_class.new(id: 27, display_name: "Allen, Stephen G.")
    expect(creator.authority_rdf).to be_an_instance_of ActiveTriples::Resource
  end
end
