# frozen_string_literal: true

module Cypripedium
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks

    included do
      self.show_presenter = CypripediumWorkPresenter
    end
  end
end
