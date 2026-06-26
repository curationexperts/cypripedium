# frozen_string_literal: true

class Export < ApplicationRecord
  enum :status, [:unknown, :queued, :working, :failed, :completed], default: :unknown
  enum :format, [:zip, :bag], scopes: false
  belongs_to :user
  has_one_attached :export_file

  validates :format, presence: true
  validates :items, length: { minimum: 1 }

  # Always uses a canonicalized array of items
  normalizes :items, with: ->(value) { Array(value).compact_blank.uniq.sort }

  def base_name
    base = "#{Rails.application.config.bag_prefix}_#{format}_#{items.first}"
    collisions = ActiveStorage::Blob.where("filename LIKE ?", base + '%').count

    return base unless collisions.positive?
    base.concat('_', collisions.next.to_s)
  end
end
