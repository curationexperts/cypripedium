# frozen_string_literal: true

require_relative '../prepends/microdata_attributes'
require_relative '../prepends/microdata_object_attributes'


# Hyrax::Renderers::AttributeRenderer.prepend(MicrodataAttributes)
Hyrax::Renderers::ConfiguredMicrodata.prepend(MicrodataObjectAttributes)
