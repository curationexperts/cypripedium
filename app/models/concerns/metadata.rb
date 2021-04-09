# frozen_string_literal: true

module Metadata
  extend ActiveSupport::Concern

  included do
    property :creator_id, predicate: RDF::Vocab::SCHEMA.identifier do |index|
      index.as :stored_searchable, :facetable
    end
    property :series, predicate: RDF::Vocab::SCHEMA.isPartOf do |index|
      index.as :stored_searchable, :facetable
    end

    property :issue_number, predicate: RDF::Vocab::SCHEMA.issueNumber do |index|
      index.as :stored_searchable, :stored_sortable
    end

    property :abstract, predicate: RDF::Vocab::DC.abstract do |index|
      index.as :stored_searchable
    end

    property :alternative_title, predicate: RDF::Vocab::DC.alternative do |index|
      index.as :stored_searchable
    end

    property :bibliographic_citation, predicate: RDF::Vocab::DC.bibliographicCitation do |index|
      index.as :stored_searchable
    end

    property :corporate_name, predicate: RDF::Vocab::MADS.CorporateName do |index|
      index.as :stored_searchable
    end

    property :date_available, predicate: RDF::Vocab::DC.available do |index|
      index.as :stored_searchable
    end

    property :extent, predicate: RDF::Vocab::DC.extent do |index|
      index.as :stored_searchable
    end

    property :has_part, predicate: RDF::Vocab::DC.hasPart do |index|
      index.as :stored_searchable
    end

    property :is_version_of, predicate: RDF::Vocab::DC.isVersionOf do |index|
      index.as :stored_searchable
    end

    property :has_version, predicate: RDF::Vocab::DC.hasVersion do |index|
      index.as :stored_searchable
    end

    property :is_replaced_by, predicate: RDF::Vocab::DC.isReplacedBy do |index|
      index.as :stored_searchable
    end

    property :replaces, predicate: RDF::Vocab::DC.replaces do |index|
      index.as :stored_searchable
    end

    property :requires, predicate: RDF::Vocab::DC.requires do |index|
      index.as :stored_searchable
    end

    property :geographic_name, predicate: RDF::Vocab::DC.spatial do |index|
      index.as :stored_searchable
    end

    property :table_of_contents, predicate: RDF::Vocab::DC.tableOfContents do |index|
      index.as :stored_searchable
    end

    property :temporal, predicate: RDF::Vocab::DC.temporal do |index|
      index.as :stored_searchable
    end
  end
end
