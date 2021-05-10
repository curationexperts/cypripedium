# frozen_string_literal: true
class CreatorReindexJob < Hyrax::ApplicationJob
  def perform(creator_id)
    Creator.find(creator_id).reindex_associated_works
  end
end
