# frozen_string_literal: true
class Creator < ApplicationRecord
  validates :repec, :viaf, uniqueness: { message: "id already in the system", allow_blank: :true }
  validates :display_name, presence: :true
  serialize :alternate_names, type: Array
  after_save :reindex_setup

  def reindex_setup
    CreatorReindexJob.perform_later self
  end

  def reindex_associated_works
    solr = Blacklight.default_index.connection
    response = solr.get 'select', params: { q: "creator_id_ssim:#{id}" }
    response['response']['docs'].each do |doc|
      ActiveFedora::Base.find(doc['id']).update_index
    end
  end

  def authority_uri
    "#{Rails.application.config.rdf_uri}/authorities/show/creator_authority/#{id}"
  end

  def authority_rdf
    ActiveTriples::Resource.new authority_uri
  end
end
