# frozen_string_literal: true
##
# This class is initilized wih a string and level (info, error) and then outputs
# the message to the console and a file. The levels are listed here:
# https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html
module Contentdm
  class Log
    ##
    # @param [String] message level
    def initialize(message, level, file = nil)
      file = File.open(Rails.root.join('log', 'contentdm_import.log'), 'a') if file.nil?
      # Logger for the console
      std_out_logger = Logger.new(STDOUT)
      # Logger for the file
      file_logger = Logger.new(file)

      # Make info messages green and error messages red
      case level
      when 'info'
        std_out_logger.send(level, Rainbow(message).green)
      when 'error'
        std_out_logger.send(level, Rainbow(message).red)
      else
        std_out_logger.send(level, message)
      end

      file_logger.send(level, message)
      file_logger.close
    end
  end
end
