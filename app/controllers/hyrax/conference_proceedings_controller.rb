# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work ConferenceProceeding`

module Hyrax
  class ConferenceProceedingsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ConferenceProceeding

    # Use this line if you want to use a custom presenter
    self.show_presenter = CypripediumWorkPresenter
  end
end
