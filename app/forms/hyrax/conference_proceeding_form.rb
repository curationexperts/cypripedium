# Generated via
#  `rails generate hyrax:work ConferenceProceeding`
module Hyrax
  class ConferenceProceedingForm < Hyrax::Forms::WorkForm
    self.model_class = ::ConferenceProceeding
    self.terms += [:resource_type]
  end
end
