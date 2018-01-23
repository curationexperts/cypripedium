# frozen_string_literal: true
# This class returns an array of symbols
# that contains all of the properties that
# are defined in the `Metadata` concern
class Attributes < ActiveFedora::Base
  include Metadata
  ##
  # @return [Array<Symbol>]
  def self.to_a
    properties.except('has_model', 'create_date', 'modified_date').keys
  end
end
