# frozen_string_literal: true

module Cypripedium
  class ImageValidator
    def initialize(image:)
      @image = image
    end

    def valid?
      MiniMagick::Image.new(@image).identify
      true
    rescue MiniMagick::Error
      false
    end
  end
end
