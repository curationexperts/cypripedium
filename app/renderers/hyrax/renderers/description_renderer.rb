module Hyrax
  module Renderers
    # This is used by PresentsAttributes to render Description fields
    #   e.g.: presenter.attribute_to_html(:description, render_as: :description)
    class DescriptionRenderer < AttributeRenderer
      private

        def attribute_value_to_html(value)
          renderer = Redcarpet::Render::HTML.new(escape_html: true)
          markdown = Redcarpet::Markdown.new(renderer, autolink: true)
          markdown.render(value)
        end
    end
  end
end
