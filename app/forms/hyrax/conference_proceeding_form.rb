# Generated via
#  `rails generate hyrax:work ConferenceProceeding`
module Hyrax
  class ConferenceProceedingForm < Hyrax::Forms::WorkForm
    self.model_class = ::ConferenceProceeding
    self.terms += [:resource_type]
    self.terms += ::Attributes.to_a
  end
end
