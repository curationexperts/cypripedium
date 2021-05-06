# frozen_string_literal: true
module Hyrax
  class CypripediumForm < Hyrax::Forms::WorkForm
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
      result[:related_url]&.map! { |related_url| RDF::Markdown::Literal.new(related_url) }
      result[:description]&.map! { |description| RDF::Markdown::Literal.new(description) }
      result[:abstract]&.map! { |abstract| RDF::Markdown::Literal.new(abstract) }
      result
    end

    # This describes the parameters we are expecting to receive from the client
    # @return [Array] a list of parameters used by sanitize_params
    def self.build_permitted_params
      super + [
        :on_behalf_of,
        :version,
        :add_works_to_collection,
        {
          creator_id_attributes: [:id, :_destroy],
          based_near_attributes: [:id, :_destroy],
          member_of_collections_attributes: [:id, :_destroy],
          work_members_attributes: [:id, :_destroy]
        }
      ]
    end
  end
end
