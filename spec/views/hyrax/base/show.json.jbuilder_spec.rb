# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'hyrax/base/show.json.jbuilder', type: :view do
  let(:solr_document) do
    SolrDocument.new(
    # minimal metadata
    {
      "has_model_ssim": ["Publication"],
      "id": "dummy_id",
      "title_tesim": ["Title"],
      "creator_tesim": ["Delahaye, Jacquotte", "Back From The Dead Red", "anon. 17th Century"],
      "alpha_creator_tesim": ["anon. 17th Century", "Delahaye, Jacquotte"]
    }
  )
  end
  let(:presenter) { CypripediumWorkPresenter.new(solr_document, nil) }
  let(:curation_concern) { Hyrax::Work.new({ id: solr_document[:id], persisted: true }) }
  let(:json) do
    rendered = ApplicationController.render template: subject,
                                            format: :json,
                                            assigns: { curation_concern: curation_concern, presenter: presenter }
    JSON.parse(rendered)
  end

  before do
    resource = Wings::ActiveFedoraConverter.convert(resource: curation_concern)
    allow(Wings::ActiveFedoraConverter).to receive(:convert).and_return(resource)
    allow(resource).to receive(:etag).and_return('not persisted')
  end

  it 'alphabetizes creator names' do
    expect(json['creator']).to eq ["anon. 17th Century", "Delahaye, Jacquotte"]
  end
end
