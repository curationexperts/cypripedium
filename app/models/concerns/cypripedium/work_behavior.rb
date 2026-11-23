# frozen_string_literal: true

module Cypripedium
  module WorkBehavior
    extend ActiveSupport::Concern

    included do
      include ::Hyrax::WorkBehavior
      include ::Cypripedium::Metadata
      include ::Hyrax::BasicMetadata

      validates :title, presence: { message: 'Your work must have a title.' }
      self.indexer = CypripediumIndexer
    end
  end
end
