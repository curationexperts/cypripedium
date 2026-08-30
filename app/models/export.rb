# frozen_string_literal: true

class Export < ApplicationRecord
  enum :status, [:unknown, :queued, :working, :failed, :completed], default: :unknown
  enum :format, [:zip, :bag], scopes: false, default: :bag
  belongs_to :user
  has_one_attached :export_file

  validates :format, presence: true
  validates :items, length: { minimum: 1 }
  validates :filename, length: { maximum: 250 }, allow_nil: true
  validates :filename, format: { with: /\A[A-Z]/i, message: 'must start with a letter' }, allow_nil: true
  validates :filename, format: { with: /\A[A-Z0-9_.-]*\z/i, message: 'must use only letters, numbers, periods, hyphens, and underscores' }, allow_nil: true

  # Always uses a canonicalized array of items
  normalizes :items, with: ->(value) { Array(value).compact_blank.uniq.sort }
  # Normalize blank filenames to nil
  normalizes :filename, with: ->(value) { value.presence }

  def base_filename
    filename || default_filename
  end

  def default_filename
    base = "#{Rails.application.config.bag_prefix}_#{format}_#{items.first}"
    collisions = ActiveStorage::Blob.where("filename LIKE ?", base + '%').count

    return base unless collisions.positive?
    base.concat('_', collisions.next.to_s)
  end

  def duplicate_records
    @duplicate_records ||= Export.where(items: items).where.not(id: id).to_a
  end

  def duplicates?
    duplicate_records.any?
  end
end
