# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Publication`
module Hyrax
  class ImageForm < CypripediumForm
    self.model_class = ::Image

    def primary_terms
      [:title, :creator_id, :date_created, :keyword, :description, :source, :temporal,
       :related_url, :publisher, :rights_statement, :resource_type, :license]
    end

    def secondary_terms
      [:contributor, :corporate_name, :series, :issue_number, :abstract, :subject, :identifier, :language, :alternative_title, :bibliographic_citation,
       :date_available, :extent, :has_part, :is_version_of, :has_version, :is_replaced_by, :replaces, :requires,
       :geographic_name, :table_of_contents]
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
      super
      # super + [
      #   :on_behalf_of,
      #   :version,
      #   :add_works_to_collection,
      #   {
      #     creator_id_attributes: [:id, :_destroy],
      #     based_near_attributes: [:id, :_destroy],
      #     member_of_collections_attributes: [:id, :_destroy],
      #     work_members_attributes: [:id, :_destroy]
      #   }
      # ]
    end
  end
end
