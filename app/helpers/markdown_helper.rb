module MarkdownHelper
  # Temporarily disable rubocop rule to mark the
  # rendered strings as html_safe.
  # rubocop:disable Rails/OutputSafety
  def render_with_markdown(args)
    renderer = Redcarpet::Render::HTML.new({})
    markdown = Redcarpet::Markdown.new(renderer, autolink: true)

    # Run user input values through a sanitizer
    # before marking the strings as html_safe.
    rendered_values = args[:value].map do |value|
      sanitized_value = sanitize(value)
      markdown.render(sanitized_value).html_safe
    end

    safe_join(rendered_values, ' ')
  end
  # rubocop:enable Rails/OutputSafety
end
