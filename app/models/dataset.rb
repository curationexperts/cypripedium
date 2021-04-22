# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Dataset`
class Dataset < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = DatasetIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  include Metadata
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
  id_blank = proc { |attributes| attributes[:id].blank? }
  accepts_nested_attributes_for :creator_id, reject_if: id_blank, allow_destroy: true
end
