# frozen_string_literal: true

class Export < ApplicationRecord
  enum :status, [:unknown, :queued, :working, :failed, :completed], default: :unknown
  enum :format, [:zip, :bag], scopes: false
  belongs_to :user
  has_one_attached :export_file

  validates :format, presence: true
  validates :items, length: { minimum: 1 }
end
