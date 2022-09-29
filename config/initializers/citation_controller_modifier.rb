# frozen_string_literal: true

Hyrax::CitationsController.class_eval do
  def show_presenter
    Hyrax::CitationPresenter
  end
end
