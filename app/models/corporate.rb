# frozen_string_literal: true
class Corporate < ApplicationRecord
  validates :corporate_name, uniqueness: { message: "id already in the system", allow_blank: :false }
  validates :corporate_name, :corporate_state, :corporate_city, presence: :true
  after_save :reindex_setup

  def reindex_setup
    CorporateReindexJob.perform_later id
  end

  def reindex_associated_works
    solr = Blacklight.default_index.connection
    response = solr.get 'select', params: { q: "corporate_id_ssim:#{id}" }
    response['response']['docs'].each do |doc|
      CypripediumWork.find(doc['id']).update_index
    end
  end

  def authority_uri
    "#{Rails.application.config.rdf_uri}/authorities/show/corporate_authority/#{id}"
  end

  def authority_rdf
    ActiveTriples::Resource.new authority_uri
  end
end
