# frozen_string_literal: true

class HomepageController < Hyrax::HomepageController
  # Override this method from Hyrax so that we can
  # feature certain collection on the home page.
  def collections(rows: 5)
    HomepageCollection.all
  end
end
