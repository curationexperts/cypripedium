# frozen_string_literal: true

module MarkdownHelper
  def render_with_markdown(args)
    # Use escape_html to sanitize the user inputs so we can later mark it as html_safe.
    renderer = Redcarpet::Render::HTML.new(escape_html: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true)

    rendered_values = args[:value].map do |value|
      # rubocop:disable Rails/OutputSafety
      markdown.render(value).html_safe
      # rubocop:enable Rails/OutputSafety
    end

    safe_join(rendered_values, ' ')
  end
end
