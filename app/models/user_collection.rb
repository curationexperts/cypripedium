# frozen_string_literal: true
class UserCollection < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :collections, presence: true
  serialize :collections, Array
end
