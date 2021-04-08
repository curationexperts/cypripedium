# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Publication do
  let(:work) { FactoryBot.build(:publication) }
  let(:creator) { FactoryBot.create(:creator, id: 1234) }

  it_behaves_like 'a work with additional metadata'
  it "can set and retrieve a creator value" do
    publication = Publication.new
    publication.title = ["Some title, cuz it's required"]
    publication.creator = [creator.display_name]
    publication.creator_id = [creator.id]
    publication.save!
    expect(publication.creator).to eq(["Alvarez, Fernando, 1964-"])
    expect(publication.creator_id).to eq([1234])
    expect(publication.creator).to be_an_instance_of ActiveTriples::Relation
  end
end
