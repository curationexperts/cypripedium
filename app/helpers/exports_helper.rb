# frozen_string_literal: true
module ExportsHelper
  def work_path(doc)
    main_app.polymorphic_path(doc)
  rescue NoMethodError, ArgumentError, ActionController::UrlGenerationError
    nil
  end
end
