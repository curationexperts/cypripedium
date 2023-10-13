# frozen_string_literal: true

require 'hyrax/controlled_vocabularies/location'
class CypripediumWork < ActiveFedora::Base
  def self.inherited(subclass)
    subclass.include 'Hyrax::WorkBehavior'.constantize
    subclass.indexer = CypripediumIndexer
  end

  validates :title, presence: { message: 'Your work must have a title.' }
  self.indexer = CypripediumIndexer

  # Common metadata terms provided by Hyrax
  include ::Hyrax::BasicMetadata
  # Local application additions to metadata terms
  include ::Metadata

  # Returns a list of property names added via the local Metadata concern
  def self.added_attributes
    PropertyCounter.included_properties
  end

  private

  # Accumulates the ActiveFedora properties added in the local applicaton
  # from the Metada concern.  Does not include properties from Hyrax::BasicMetadata
  class PropertyCounter
    @@included_properties = []

    def self.property(name, **args)
      @@included_properties << name.to_s
    end

    def self.included_properties
      @@included_properties
    end

    # Include any property definitions added to the parent class in the local application
    include ::Metadata
  end
end
