# frozen_string_literal: true

class Publication < ActiveFedora::Base
  validates :title, presence: { message: 'Your work must have a title.' }

  include Hyrax::WorkBehavior
  include Cypripedium::Metadata
  include ::Hyrax::BasicMetadata

  self.indexer = CypripediumIndexer
end
