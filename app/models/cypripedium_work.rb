# frozen_string_literal: true

require 'hyrax/controlled_vocabularies/location'
class CypripediumWork < ActiveFedora::Base
  def self.inherited(subclass)
    subclass.include 'Hyrax::WorkBehavior'.constantize
    subclass.indexer = CypripediumIndexer
  end
  include Metadata

  validates :title, presence: { message: 'Your work must have a title.' }
  self.indexer = CypripediumIndexer
  include ::Hyrax::BasicMetadata

  def load_creators_from_ids
    return unless creator_id

    ids = JSON.parse(creator_id.first)

    self.creator = ids.map do |creator_id|
      Creator.find_by(id: creator_id)&.display_name
    end.compact
  end
end
