# frozen_string_literal: true

# Override #warn method to handle different API expectations
# i.e. old Deprecation gem API or ActiveSupport::Deprecation API
# Signatures:
#   def warn(context, message = nil, callstack = nil) - cbeer/deprecation gem
#   def warn(context, message = nil, callstack = nil) - ActiveSupport::Deprecation
#
module Extensions
  module DeprecationReporting
    def self.included(k)
      k.class_eval do
        def self.warn(*args)
          return if Rails.application.config.active_support.deprecation == :silence

          if args[0].is_a?(String)
            message, callstack = args[0..1]
          else
            context, message, callstack = args[0..2]
          end

          return if context.respond_to?(:silenced?) && context.silenced?

          if callstack.nil?
            callstack = caller
            callstack.shift
          end

          deprecation_message(callstack, message).tap do |m|
            deprecation_behavior(context).each { |b| b.call(m, sanitized_callstack(callstack)) }
          end
        end
      end
    end
  end
end
