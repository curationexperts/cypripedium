# frozen_string_literal: true

# This is meant to add behavior to
# Hyrax::Forms::CollectionForm
# so that we can add markdown to some of the form fields.

module CollectionFormMarkdown
  def description
    description_values = super
    description_values.map { |value| RDF::Markdown::Literal.new(value) }
  end
end
