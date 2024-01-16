# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Publication`

module Hyrax
  class PublicationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Publication

    # Use this line if you want to use a custom presenter
    self.show_presenter = CypripediumWorkPresenter
  end
end
