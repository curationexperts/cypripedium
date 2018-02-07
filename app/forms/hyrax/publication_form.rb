# Generated via
#  `rails generate hyrax:work Publication`
module Hyrax
  class PublicationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Publication
    self.terms += [:resource_type]
    self.terms += ::Attributes.to_a
    self.required_fields = [:title]

    def self.model_attributes(form_params)
      result = super
      result[:related_url].map! { |related_url| RDF::Markdown::Literal.new(related_url) }
      result
    end
  end
end
