# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'hyrax/base/show.json.jbuilder', type: :view do
  let(:curation_concern) {
    FactoryBot.build(:populated_publication,
                                            creator: ['Delahaye, Jacquotte', 'Back From The Dead Red', 'anon. 17th Century'])
  }
  let(:solr_document) {
    SolrDocument.new(
    :id => 'dummy_id',
    'system_create_dtsi' => '2024-10-11T21:18:28Z',
    'system_modified_dtsi' => '2024-10-11T21:18:28Z',
    'has_model_ssim' => ['Publication'],
    'series_tesim' => ['Staff Report (Federal Reserve Bank of Minneapolis. Research Department)'],
    'series_sim' => ['Staff Report (Federal Reserve Bank of Minneapolis. Research Department)'],
    'abstract_tesim' => ['This is my abstract'],
    'description_tesim' => ['This is my description'], 'identifier_tesim' => ['https://doi.org/10.21034/sr.600'],
    'title_tesim' => ['The 1929 Stock Market: Irving Fisher Was Right: Additional Files'],
    'title_sim' => ['The 1929 Stock Market: Irving Fisher Was Right: Additional Files'],
    'title_ssi' => 'The 1929 Stock Market: Irving Fisher Was Right: Additional Files',
    'resource_type_tesim' => ['Dataset'],
    'resource_type_sim' => ['Dataset'],
    'creator_tesim' => ['Delahaye, Jacquotte', 'Back From The Dead Red', 'anon. 17th Century'],
    'creator_sim' => ['Delahaye, Jacquotte', 'Back From The Dead Red', 'anon. 17th Century'],
    'alpha_creator_tesim' => ['anon. 17th Century', 'Back From The Dead Red', 'Delahaye, Jacquotte']
  )
  }
  let(:presenter) { CypripediumWorkPresenter.new(solr_document, nil) }
  let(:json) do
    rendered = ApplicationController.render template: subject,
                                            format: :json,
                                            assigns: { curation_concern: curation_concern, presenter: presenter }
    JSON.parse(rendered)
  end

  before do
    allow(curation_concern).to receive(:etag).and_return('not persisted')
  end

  it 'alphabetizes creator names' do
    expect(json['creator']).to eq ['anon. 17th Century', 'Back From The Dead Red', 'Delahaye, Jacquotte']
  end
end
