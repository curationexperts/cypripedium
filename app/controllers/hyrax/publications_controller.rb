# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Publication`

module Hyrax
  class PublicationsController < ApplicationController
    include Cypripedium::WorksControllerBehavior
    self.curation_concern_type = ::Publication
  end
end
