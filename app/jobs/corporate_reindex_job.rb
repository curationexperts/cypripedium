# frozen_string_literal: true
class CorporateReindexJob < Hyrax::ApplicationJob
  def perform(corporate_id)
    Corporate.find(corporate_id).reindex_associated_works
  end
end
