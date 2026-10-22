# frozen_string_literal: true

module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  # The application only supports English,
  # so we need to override Hyrax's defult langsage options.
  def available_translations
    {
      'en' => 'English'
    }
  end
end
