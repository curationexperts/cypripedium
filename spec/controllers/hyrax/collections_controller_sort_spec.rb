# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::CollectionsController, clean_repo: true do
  DATE_PUBLISHED_ARRAY = [['2015-10-15'], ['2018-11'], ['2020-02-28']].freeze
  DATE_MODIFIED_ARRAY  = ['2020-10-25', '2021-10-25', '2022-10-25'].freeze
  TITLE_ARRAY = [['publication1'], ['publication2'], ['publication3']].freeze
  ISSUE_NUMBER_ARRAY = [['20'], ['30'], ['40']].freeze

  routes { Hyrax::Engine.routes }
  let(:user) { FactoryBot.create(:admin) }

  let(:collection) do
    coll = Collection.new(
    title: ['Collection 1'],
    collection_type: Hyrax::CollectionType.find_or_create_default_collection_type,
    description: ['Old Description']
    )
    coll.apply_depositor_metadata(user.user_key)
    coll.save!
    coll
  end

  let(:asset1) do
    FactoryBot.create(
    :publication,
    title: TITLE_ARRAY[0],
    date_created: DATE_PUBLISHED_ARRAY[0],
    date_modified: DATE_MODIFIED_ARRAY[0],
    issue_number: ISSUE_NUMBER_ARRAY[0],
    edit_users: [user.user_key],
    read_users: [user.user_key]
    )
  end

  let(:asset2) do
    FactoryBot.create(
    :publication,
    title: TITLE_ARRAY[1],
    date_created: DATE_PUBLISHED_ARRAY[1],
    date_modified: DATE_MODIFIED_ARRAY[1],
    issue_number: ISSUE_NUMBER_ARRAY[1],
    edit_users: [user.user_key],
    read_users: [user.user_key]
    )
  end

  let(:asset3) do
    FactoryBot.create(
    :publication,
    title: TITLE_ARRAY[2],
    date_created: DATE_PUBLISHED_ARRAY[2],
    date_modified: DATE_MODIFIED_ARRAY[2],
    issue_number: ISSUE_NUMBER_ARRAY[2],
    edit_users: [user.user_key],
    read_users: [user.user_key]
    )
  end

  describe "#show" do
    context "when signed in" do
      before do
        sign_in user
        if collection.is_a? Valkyrie::Resource
          Hyrax::Collections::CollectionMemberService.add_members(
            collection_id: collection.id,
            new_members: [asset1, asset2, asset3],
            user: user
          )
        else
          [asset1, asset2, asset3].each do |asset|
            asset.member_of_collections << collection
            asset.save
            sleep(5)
          end
        end
      end

      it "returns the collection and its members" do
        get :show, params: { id: collection }
        expect(response).to be_successful
        expect(response).to render_template("layouts/hyrax/1_column")
        expect(assigns[:member_docs].map(&:id)).to match_array [asset1, asset2, asset3].map(&:id)
      end

      it "sort the collection members by title desc" do
        get :show, params: { id: collection, sort: 'title_ssi desc' }
        expect(response).to be_successful
        expect(assigns[:member_docs].map(&:title)).to eq TITLE_ARRAY.reverse
      end

      it "sort the collection members by title asc" do
        get :show, params: { id: collection, sort: 'title_ssi asc' }
        expect(response).to be_successful
        expect(assigns[:member_docs].map(&:title)).to eq TITLE_ARRAY
      end

      it "sort the collection members by issue_number asc" do
        get :show, params: { id: collection, sort: 'issue_number_ssi asc' }
        expect(response).to be_successful
        expect(assigns[:member_docs].map(&:issue_number)).to eq ISSUE_NUMBER_ARRAY
      end

      it "sort the collection members by issue_number desc" do
        get :show, params: { id: collection, sort: 'issue_number_ssi desc' }
        expect(response).to be_successful
        expect(assigns[:member_docs].map(&:issue_number)).to eq ISSUE_NUMBER_ARRAY.reverse
      end

      it "sort the collection members by date_created asc" do
        get :show, params: { id: collection, sort: 'date_created_ssi asc' }
        expect(response).to be_successful
        expect(assigns[:member_docs].map(&:date_created)).to eq DATE_PUBLISHED_ARRAY
      end

      it "sort the collection members by date_created desc" do
        get :show, params: { id: collection, sort: 'date_created_ssi desc' }
        expect(response).to be_successful
        expect(assigns[:member_docs].map(&:date_created)).to eq DATE_PUBLISHED_ARRAY.reverse
      end

      it "sort the collection members by date_modified asc" do
        get :show, params: { id: collection, sort: 'system_modified_dtsi asc' }
        expect(response).to be_successful
        expect(assigns[:member_docs].map(&:title)).to eq TITLE_ARRAY
      end

      it "sort the collection members by date_modified desc" do
        get :show, params: { id: collection, sort: 'system_modified_dtsi desc' }
        expect(response).to be_successful
        expect(assigns[:member_docs].map(&:title)).to eq TITLE_ARRAY.reverse
      end
    end
  end
end
