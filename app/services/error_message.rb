# frozen_string_literal: true

# Short, single-line summaries of exception messages.
module ErrorMessage
  # @param exception [Exception]
  # @return [String] the first line of the message, truncated to 120 characters,
  #   or the exception class name when the message is blank
  #
  # @example
  #   ErrorMessage.for(StandardError.new("Disk full\nat line 3")) #=> "Disk full"
  #   ErrorMessage.for(Ldp::Gone.new(''))                        #=> "Ldp::Gone"
  def self.for(exception)
    first_line = exception.message.each_line(chomp: true).first.presence || exception.class.name
    first_line.truncate(120, omission: '…')
  end
end
