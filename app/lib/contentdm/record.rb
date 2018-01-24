# frozen_string_literal: true
# This class represents a record in the ContentDM XML
# export:
#
#   <record>
#    <title>Classical macroeconomic model for the United States, a / Thomas J. Sargent.</title>
#    <creator>Sargent, Thomas J.</creator>
# To use the class, pass it an XML document that has been
# opened with Nokogiri:
# cdm_record = ContentdmRecord.new(record_xml)
#
# then you can access the properties:
# cdm_record.title
# > "Classical macroeconomic model for the United States, a"
module Contentdm
  class Record
    ##
    # @param record_xml [Nokogiri::XML::Document]
    # Give this class a Nokogiri::XML::Document and it will
    # create a Hash
    def initialize(record_xml)
      @record_xml = record_xml
      @record_hash = Hash.from_xml(record_xml.to_xml)["record"]
    end

    ##
    # @return [String] Returns the legacyFileName element
    def legacy_file_name
      @record_hash["legacyFileName"]
    end

    ##
    # @return [Array<String>]
    # the title without the / Author, Name
    # part at the end and without any spaces at the end
    def title
      get_values(@record_hash["title"]).map { |title| title.split('/')[0].strip! }
    end

    ##
    # @return [Array<String>]
    # returns the creators
    def creator
      get_values(@record_hash["creator"])
    end

    ##
    # @return [Array<String>]
    # returns the contributors
    def contributor
      get_values(@record_hash["contributor"])
    end

    ##
    # @return [Array<String>]
    # returns the subjects
    def subject
      get_values(@record_hash["subject"])
    end

    ##
    # @return [Array<String>]
    # returns the descriptions
    def description
      get_values(@record_hash["description"])
    end

    ##
    # @return [Array<String>]
    # returns the date_created
    def date_created
      get_values(@record_hash["created"])
    end

    ##
    # @return [Array<String>]
    # returns the abstract
    def abstract
      get_values(@record_hash["abstract"])
    end

    ##
    # @return [Array<String>]
    # returns the publisher
    def publisher
      get_values(@record_hash["publisher"])
    end

    ##
    # @return [Array<String>]
    # returns the requires attribute
    def requires
      get_values(@record_hash["requires"])
    end

    ##
    # @return [String]
    # returns the type of work that will determine the model
    def work_type
      @record_hash["work_type"]
    end

    ##
    # @return [String]
    # returns a table of contents
    def table_of_contents
      get_values(@record_hash["tableOfContents"])
    end

    private

      # @param values [String, Array] The value(s) for a single property
      # @return [Array] Returns an array of values with extra whitespace and nil values stripped out.
      def get_values(values)
        values = Array(values)
        values = remove_nils(values)
        strip_whitespace(values)
      end

      ##
      # @param property [Array]
      # @return [Array]
      # this will remove any blanks in the processed XML
      def remove_nils(property)
        property.select { |prop| !prop.nil? }
      end

      def strip_whitespace(values)
        values.map { |v| v.strip }
      end
  end
end
