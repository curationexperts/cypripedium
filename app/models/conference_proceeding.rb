# frozen_string_literal: true

class ConferenceProceeding < CypripediumWork
  include ::Hyrax::BasicMetadata
  id_blank = proc { |attributes| attributes[:id].blank? }
  accepts_nested_attributes_for :creator_id, reject_if: id_blank, allow_destroy: true
end
