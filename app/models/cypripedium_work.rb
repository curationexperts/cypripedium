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
end
