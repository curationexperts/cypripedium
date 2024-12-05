# frozen_string_literal: true

class ConferenceProceeding < ActiveFedora::Base
  validates :title, presence: { message: 'Your work must have a title.' }
  self.indexer = CypripediumIndexer

  include Hyrax::WorkBehavior
  include Metadata
  include Hyrax::BasicMetadata
end
