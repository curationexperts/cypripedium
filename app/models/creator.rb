# frozen_string_literal: true
class Creator < ApplicationRecord
  validates :repec, :viaf, uniqueness: { message: "id already in the system", allow_blank: :true }
  validates :display_name, presence: :true
  serialize :alternate_names, Array
  def alternate_names=(alternate_names)
    alternate_names = alternate_names.split(' ; ') if alternate_names.is_a?(String)
    super(alternate_names)
  end
end
