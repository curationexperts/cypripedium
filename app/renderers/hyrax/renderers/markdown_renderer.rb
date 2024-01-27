# frozen_string_literal: true

module Hyrax
  module Renderers
    # This is used by PresentsAttributes to render fields that include Markdown formatting
    #   e.g.: presenter.attribute_to_html(:abstract, render_as: :markdown)
    class MarkdownRenderer < AttributeRenderer
      private

      def attribute_value_to_html(value)
        renderer = Redcarpet::Render::HTML.new(escape_html: true)
        markdown = Redcarpet::Markdown.new(renderer, autolink: true)
        if microdata_value_attributes(field)
          "<span#{html_attributes(microdata_value_attributes(field))}>#{markdown.render(value)}</span>"
        else
          markdown.render(value)
        end
      end
    end
  end
end
