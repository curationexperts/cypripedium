# frozen_string_literal: true

# require 'hyrax/controlled_vocabularies/location'
class CypripediumWork < ::ActiveFedora::Base
  # def self.inherited(subclass)
  #   subclass.
  #   subclass.indexer = CypripediumIndexer
  #   subclass.include ::Hyrax::BasicMetadata
  # end
  validates :title, presence: { message: 'Your work must have a title.' }

  include Hyrax::WorkBehavior
  include Metadata
  include Hyrax::BasicMetadata

  self.indexer = CypripediumIndexer
end
