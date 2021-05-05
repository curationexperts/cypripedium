# frozen_string_literal: true
class Creator < ApplicationRecord
  validates :repec, :viaf, uniqueness: { message: "id already in the system", allow_blank: :true }
  validates :display_name, presence: :true
  serialize :alternate_names, Array
  after_save :reindex_associated_works

  def reindex_associated_works
    Publication.where(creator_id_ssim: id.to_s).find_each do |record|
      record.update_index
    end
    Dataset.where(creator_id_ssim: id.to_s).find_each do |record|
      record.update_index
    end
    ConferenceProceeding.where(creator_id_ssim: id.to_s).find_each do |record|
      record.update_index
    end
  end

  def authority_uri
    "#{Rails.application.config.rdf_uri}/authorities/show/creator_authority/#{id}"
  end

  def authority_rdf
    ActiveTriples::Resource.new authority_uri
  end

end
