module MicrodataObjectAttributes

  # def microdata_object?(field)
  #   return true if field == :abstract
  #   return false unless Hyrax.config.display_microdata?
  #   translate_microdata(field: field, field_context: 'type', default: false)
  # end

  def microdata_object_attributes(field)
    # For some reason identifier behaves differently than other attributes
    return {} if field == :identifier
    if microdata_object?(field)
      { itemprop: microdata_property(field), itemscope: '', itemtype: microdata_type(field) }
    elsif microdata_attribute?(field)
      { itemprop: microdata_property(field) }
    else
      {}
    end
  end

  def microdata_attribute?(field)
      return false unless Hyrax.config.display_microdata?
      return true if translate_microdata(field: field, field_context: 'property', default: false)
  end
end
