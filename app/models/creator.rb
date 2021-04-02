# frozen_string_literal: true
class Creator < ApplicationRecord
  validates :repec, :viaf, uniqueness: {message: "id already in the system", allow_blank: :true}
  validates :display_name, presence: :true
end
