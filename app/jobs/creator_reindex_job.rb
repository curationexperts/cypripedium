# frozen_string_literal: true
class CreatorReindexJob < ApplicationJob
  def perform(creator)
    creator.reindex_associated_works
  end
end
