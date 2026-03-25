# frozen_string_literal: true

# Override the #available_member_works
# default to sort by volume & issue number
# when no user supplied search sort parameters are present
module Extensions
  module PresentsAttributes
    def self.included(k)
      k.class_eval do
        private

        def find_renderer_class(name)
          render_class = "#{name.to_s.camelize}AttributeRenderer".to_sym
          if Hyrax::Renderers.const_defined?(render_class)
            Hyrax::Renderers.const_get(render_class)
          else
            Hyrax.logger.error("Invalid attribute renderer Hyrax::#{render_class}, using 'Hyrax::AttributeRenderer'")
            Renderers::AttributeRenderer
          end
        end
      end
    end
  end
end
