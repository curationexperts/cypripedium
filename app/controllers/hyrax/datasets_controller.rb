# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Dataset`

module Hyrax
  class DatasetsController < ApplicationController
    include Cypripedium::WorksControllerBehavior
    self.curation_concern_type = ::Dataset
  end
end
