module MicrodataAttributes
  # Draw the table row for the attribute
  def render
    markup = ''
    return markup if values.blank? && !options[:include_empty]
    markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    attributes = microdata_object_attributes(field)
    attributes = attributes.merge(:itemprop => "abstract") if field == :abstract
    attributes = attributes.merge(class: "attribute attribute-#{field}")
    # byebug if field == :abstract

    Array(values).each do |value|
      markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value.to_s)}</li>"
    end
    markup << %(</ul></td></tr>)
    markup.html_safe
  end
end
