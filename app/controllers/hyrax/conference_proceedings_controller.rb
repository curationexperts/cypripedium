# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work ConferenceProceeding`

module Hyrax
  class ConferenceProceedingsController < ApplicationController
    include Cypripedium::WorksControllerBehavior
    self.curation_concern_type = ::ConferenceProceeding
  end
end
