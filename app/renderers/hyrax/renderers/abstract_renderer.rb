# frozen_string_literal: true

module Hyrax
  module Renderers
    # This is used by PresentsAttributes to render Abstract fields
    #   e.g.: presenter.attribute_to_html(:abstract, render_as: :abstract)
    class AbstractRenderer < AttributeRenderer
      private

        def attribute_value_to_html(value)
          renderer = Redcarpet::Render::HTML.new(escape_html: true)
          markdown = Redcarpet::Markdown.new(renderer, autolink: true)
          markdown.render(value)
          if microdata_value_attributes(field).present?
            "<span#{html_attributes(microdata_value_attributes(field))}>#{li_value(value)}</span>"
          else
            li_value(value)
          end
        end
    end
  end
end
