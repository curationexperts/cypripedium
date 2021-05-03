# frozen_string_literal: true
class Creator < ApplicationRecord
  validates :repec, :viaf, uniqueness: { message: "id already in the system", allow_blank: :true }
  validates :display_name, presence: :true
  serialize :alternate_names, Array
  after_save :reindex_associated_works

  def reindex_associated_works

  end
end
