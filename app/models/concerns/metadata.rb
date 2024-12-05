# frozen_string_literal: true

module Metadata
  extend ActiveSupport::Concern
  LOCAL_ATTRIBUTES = {
    creator_id:     { predicate: RDF::Vocab::SCHEMA.identifier,   index_as: [:symbol]},
    series:         { predicate: RDF::Vocab::SCHEMA.isPartOf,     index_as: [:stored_searchable, :facetable] },
    issue_number:   { predicate: RDF::Vocab::SCHEMA.issueNumber,  index_as: [:stored_searchable, :stored_sortable] },
    abstract:       { predicate: RDF::Vocab::DC.abstract,         index_as: [:stored_searchable] },
    alternative_title: { predicate: RDF::Vocab::DC.alternative,   index_as: [:stored_searchable] },
    bibliographic_citation: { predicate: RDF::Vocab::DC.bibliographicCitation, index_as: [:stored_searchable] },
    corporate_name: { predicate: RDF::Vocab::MADS.CorporateName,  index_as: [:stored_searchable] },
    date_available: { predicate: RDF::Vocab::DC.available,        index_as: [:stored_searchable] },
    extent:         { predicate: RDF::Vocab::DC.extent,           index_as: [:stored_searchable] },
    has_part:       { predicate: RDF::Vocab::DC.hasPart,          index_as: [:stored_searchable] },
    is_version_of:  { predicate: RDF::Vocab::DC.isVersionOf,      index_as: [:stored_searchable] },
    has_version:    { predicate: RDF::Vocab::DC.hasVersion,       index_as: [:stored_searchable] },
    is_replaced_by: { predicate: RDF::Vocab::DC.isReplacedBy,     index_as: [:stored_searchable] },
    replaces:       { predicate: RDF::Vocab::DC.replaces,         index_as: [:stored_searchable] },
    requires:       { predicate: RDF::Vocab::DC.requires,         index_as: [:stored_searchable] },
    geographic_name: {predicate: RDF::Vocab::DC.spatial,          index_as: [:stored_searchable] },
    table_of_contents:{predicate: RDF::Vocab::DC.tableOfContents, index_as: [:stored_searchable] },
    temporal:       { predicate: RDF::Vocab::DC.temporal,         index_as: [:stored_searchable] }
  }

  included do

    LOCAL_ATTRIBUTES.each do |attribute_name, settings|
      property attribute_name, predicate: settings[:predicate] do |index|
        index.as(*settings[:index_as])
      end
    end

    def self.metadata_attribute_names
      @metadata_attribute_names ||= LOCAL_ATTRIBUTES.keys.map(&:to_s)
    end

  end
end
