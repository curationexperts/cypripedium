module MicrodataObjectAttributes

  # def microdata_object?(field)
  #   return true if field == :abstract
  #   return false unless Hyrax.config.display_microdata?
  #   translate_microdata(field: field, field_context: 'type', default: false)
  # end

  def microdata_object_attributes(field)
    # byebug if field == :abstract
    if microdata_object?(field)
      { itemprop: microdata_property(field), itemscope: '', itemtype: microdata_type(field) }
    elsif field == :abstract
      { itemprop: microdata_property(field) }
    else
      {}
    end
  end
end
