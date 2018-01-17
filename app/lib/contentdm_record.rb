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
# then you can access the pro perties:
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
    # @return [String] Returns the identifier element
    def identifer
      @record_hash["identifier"]
    end

    ##
    # @return [Array<String>]
    # the title without the / Author, Name
    # part at the end and without any spaces at the end
    def title
      [@record_hash["title"].split('/')[0].strip!]
    end

    ##
    # @return [Array<String>]
    # returns the creators
    def creators
      remove_nils(@record_hash["creator"])
    end

    ##
    # @return [Array<String>]
    # returns the contributors
    def contributors
      remove_nils([@record_hash["contributor"]])
    end

    ##
    # @return [Array<String>]
    # returns the subjects
    def subjects
      remove_nils(@record_hash["subject"])
    end

    ##
    # @return [Array<String>]
    # returns the descriptions
    def descriptions
      remove_nils([@record_hash["description"]])
    end

    ##
    # @return [Array<String>]
    # returns the date_created
    def date_created
      remove_nils([@record_hash["created"]])
    end

    ##
    # @return [Array<String>]
    # returns the publisher
    def publishers
      remove_nils([@record_hash["publisher"]])
    end

  private

    ##
    # @param property [Array]
    # @return [Array]
    # this will remove any blanks in the processed XML
    def remove_nils(property)
      property.select { |prop| !prop.nil? }
    end
  end
end
