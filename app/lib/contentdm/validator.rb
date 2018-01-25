# frozen_string_literal: true
module Contentdm
  # This class loads a RelaxNG schema that is used to validate
  # the CDM export xml.
  class Validator
    attr_reader :result

    ##
    # @param [File] xml_file
    # @return [Array]
    # Sets the result of validation during the init
    def initialize(xml_file)
      schema_file = Rails.root.join('app', 'lib', 'contentdm', 'schema', 'cdm_export.rng')
      schema = Nokogiri::XML::RelaxNG(File.open(schema_file))
      doc = Nokogiri::XML(File.open(xml_file))
      @result = schema.validate(doc)
    end

    ##
    # @return [Boolean]
    # Returns a boolean for the validation result
    def valid?
      @result.empty?
    end

    ##
    # This method will log the result of validation and
    # raise an error if the XML is invalid
    def validate
      if valid?
        Contentdm::Log.new('XML is valid', 'info')
      else
        Contentdm::Log.new('XML is invalid', 'error')
        raise 'XML is invalid'
      end
    end
  end
end
