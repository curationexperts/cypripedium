# frozen_string_literal: true

# Override Fits characterizer #command method to call the FITS servlet
# when it is configured; otherwise use the shell command.
module Extensions
  module ServletCharacterizer
    def self.included(k)
      k.class_eval do
        def command
          if ENV['FITS_SERVLET_URL']
            "curl -k -F datafile=@#{filename} #{ENV['FITS_SERVLET_URL']}/examine"
          else
            "#{tool_path} -i \"#{filename}\""
          end
        end
      end
    end
  end
end
