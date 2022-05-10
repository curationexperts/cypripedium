# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CypripediumIndexer, clean: true do
  let(:pub_indexer) { described_class.new(publication) }
  let(:data_indexer) { described_class.new(dataset) }
  let(:conf_indexer) { described_class.new(conference_proceeding) }
  let(:publication) { Publication.new(attrs) }
  let(:dataset) { Dataset.new(attrs) }
  let(:conference_proceeding) { ConferenceProceeding.new(attrs) }
  let(:data_doc) { data_indexer.generate_solr_document }
  let(:conf_doc) { conf_indexer.generate_solr_document }

  describe '#generate_solr_document' do
    context "with Creators from the authority records" do
      let(:solr_doc) { pub_indexer.generate_solr_document }

      let(:creator_one) { FactoryBot.create(:creator, display_name: 'Kehoe, Patrick J.') }
      let(:creator_two) { FactoryBot.create(:creator, display_name: 'Backus, David', alternate_names: ['Backus, Davey', 'Backus-Up, David']) }
      let(:creator_three) { FactoryBot.create(:creator, display_name: 'Kehoe, Timothy J.') }

      let(:attrs) {
        { title: ['My Title'],
          date_created: ['1970-04-30'],
          # creator: ['Kehoe, Patrick J.', 'Backus, David', 'Kehoe, Timothy J.'],
          creator_id: [creator_one.id, creator_two.id, creator_three.id] }
      }
      it 'indexes a sortable title and date created' do
        expect(solr_doc['title_ssi']).to eq 'My Title'
        expect(solr_doc['date_created_ssi']).to eq '1970-04-30'
        expect(solr_doc['date_created_iti']).to eq 1970
        # The problem with storing them separately in Fedora is that it looks like they get re-ordered in Solr
        # Wait! But with Fedora we have to totally write over the whole array anyway, so if we find the ID in
        # the creator_id array we can replace the whole set of creator names
        creator_id_array = solr_doc['creator_id_ssim']
        expect(creator_id_array).to include creator_one.id.to_s
        expect(creator_id_array).to include creator_two.id.to_s
        expect(creator_id_array).to include creator_three.id.to_s
        creator_array = solr_doc['creator_tesim']
        expect(creator_array).to include 'Kehoe, Patrick J.'
        expect(creator_array).to include 'Backus, David'
        expect(creator_array).to include 'Backus, Davey'
        expect(creator_array).to include 'Backus-Up, David'
        expect(creator_array).to include 'Kehoe, Timothy J.'
      end
      it 'indexes the creator names in alphabetical order' do
        expect(solr_doc['alpha_creator_tesim']).to eq ['Backus, David', 'Kehoe, Patrick J.', 'Kehoe, Timothy J.']
      end
      it 'indexes for the facet' do
        expect(solr_doc['creator_sim']).to match_array(["Kehoe, Timothy J.", "Backus, David", "Kehoe, Patrick J."])
      end
      it 'indexes a dataset' do
        expect(data_doc['title_ssi']).to eq 'My Title'
        expect(data_doc['date_created_ssi']).to eq '1970-04-30'
        creator_id_array = data_doc['creator_id_ssim']
        expect(creator_id_array).to include creator_one.id.to_s
        expect(creator_id_array).to include creator_two.id.to_s
        expect(creator_id_array).to include creator_three.id.to_s
        creator_array = data_doc['creator_tesim']
        expect(creator_array).to include 'Kehoe, Patrick J.'
        expect(creator_array).to include 'Backus, David'
        expect(creator_array).to include 'Backus, Davey'
        expect(creator_array).to include 'Backus-Up, David'
        expect(creator_array).to include 'Kehoe, Timothy J.'
      end
      it 'indexes a conference proceeding' do
        expect(conf_doc['title_ssi']).to eq 'My Title'
        expect(conf_doc['date_created_ssi']).to eq '1970-04-30'
        creator_id_array = conf_doc['creator_id_ssim']
        expect(creator_id_array).to include creator_one.id.to_s
        expect(creator_id_array).to include creator_two.id.to_s
        expect(creator_id_array).to include creator_three.id.to_s
        creator_array = conf_doc['creator_tesim']
        expect(creator_array).to include 'Kehoe, Patrick J.'
        expect(creator_array).to include 'Backus, David'
        expect(creator_array).to include 'Backus, Davey'
        expect(creator_array).to include 'Backus-Up, David'
        expect(creator_array).to include 'Kehoe, Timothy J.'
      end
    end

    context 'with old data without creator ids' do
      let(:solr_doc) { pub_indexer.generate_solr_document }

      let(:attrs) {
        { title: ['My Title'],
          date_created: ['1970-04-30'],
          creator: ['Kehoe, Patrick J.', 'Backus, David', 'Kehoe, Timothy J.'] }
      }
      it 'indexes the creator names in alphabetical order' do
        expect(solr_doc['alpha_creator_tesim']).to eq ['Backus, David', 'Kehoe, Patrick J.', 'Kehoe, Timothy J.']
      end
    end
  end

  describe "#extract_year" do
    let(:extracted_year) { pub_indexer.extract_year_from_date_created }
    let(:attrs) { { date_created: date_created } }
    context "returns a 4 digit extracted_year" do
      context "for strings with only a extracted_year" do
        let(:date_created) { ['2013'] }
        example { expect(extracted_year).to eq 2013 }
      end
      context "for strings with extra text" do
        let(:date_created) { ['Winter 1980'] }
        example { expect(extracted_year).to eq 1980 }
      end
      context "and ignores era" do
        let(:date_created) { ['1500 BCE'] }
        example { expect(extracted_year).to eq 1500 }
      end
      context "for ISO extracted_year and month" do
        let(:date_created) { ['1913-05'] }
        example { expect(extracted_year).to eq 1913 }
      end
      context "for ISO date & times" do
        let(:date_created) { ['2022-05-10T15:29:41Z'] }
        example { expect(extracted_year).to eq 2022 }
      end
      context "from the first extracted_year if there are multiple years" do
        let(:date_created) { ['1370 1371 1372'] }
        example { expect(extracted_year).to eq 1370 }
      end
      context "requires leading zero padding" do
        let(:date_created) { ["0590 A.D."] }
        example { expect(extracted_year).to eq 590 }
      end
    end

    # NOTE: hyrax does not guarantee ordering, so .first might return any value in the array
    context "from multiple values" do
      let(:date_created) { ['2005-12-04', '2001-05-10'] }
      years = [2001, 2005]
      example { expect(years).to include(extracted_year) }
    end

    # NOTE: the current method does not properly handle long numbers
    context "for non-date numbers" do
      let(:date_created) { ['0987654321'] }
      example { expect(extracted_year).to eq 987 }
    end

    context "returns nil if a year can't be detected" do
      context "because date_created is not present" do
        let(:attrs) { {} }
        example { expect(extracted_year).to eq nil }
      end
      context "because date_created is nil" do
        let(:date_created) { nil }
        example { expect(extracted_year).to eq nil }
      end
      context "because date_created is an empty string" do
        let(:date_created) { [""] }
        example { expect(extracted_year).to eq nil }
      end
      context "in strings with no numeric data" do
        let(:date_created) { ["Ninteen-Hundred Twenty-One"] }
        example { expect(extracted_year).to eq nil }
      end
      context "it ignores 3-digit years" do
        let(:date_created) { ["590 A.D."] }
        example { expect(extracted_year).to eq nil }
      end
    end
  end
end
