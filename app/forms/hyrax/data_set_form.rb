# Generated via
#  `rails generate hyrax:work DataSet`
module Hyrax
  class DataSetForm < Hyrax::Forms::WorkForm
    self.model_class = ::DataSet
    self.terms += [:resource_type]
    self.terms += ::Attributes.to_a
    self.required_fields = [:title]
  end
end
