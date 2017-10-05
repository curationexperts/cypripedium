# Generated via
#  `rails generate hyrax:work Paper`
module Hyrax
  class PaperForm < Hyrax::Forms::WorkForm
    self.model_class = ::Paper
    self.terms += [:resource_type]
  end
end
