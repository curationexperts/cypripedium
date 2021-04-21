# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Publication`
module Hyrax
  class PublicationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Publication
    self.terms += [:resource_type]
    self.terms += ::Attributes.to_a
    self.required_fields = [:title]

    def primary_terms
      [:title, :series, :issue_number, :creator, :creator_id, :date_created, :keyword, :subject,
       :abstract, :description, :identifier, :related_url, :corporate_name, :publisher, :resource_type, :license]
    end

    def secondary_terms
      [:contributor, :rights_statement, :language, :source, :alternative_title, :bibliographic_citation,
       :date_available, :extent, :has_part, :is_version_of, :has_version, :is_replaced_by, :replaces, :requires,
       :geographic_name, :temporal, :table_of_contents]
    end

    def self.model_attributes(form_params)
      result = super
      result[:related_url].map! { |related_url| RDF::Markdown::Literal.new(related_url) }
      result[:description].map! { |description| RDF::Markdown::Literal.new(description) }
      result[:abstract].map! { |abstract| RDF::Markdown::Literal.new(abstract) }
      result
    end
  end
end
