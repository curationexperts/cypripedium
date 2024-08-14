# frozen_string_literal: true
module Hyrax
  module Renderers
    # This is used by PresentsAttributes to show licenses
    #   e.g.: presenter.attribute_to_html(:license, render_as: :license)
    class LicenseAttributeRenderer < AttributeRenderer
      private

      ##
      # Overridden from hyrax to re-enable standard microdata support.
      # Special treatment for license/rights.  A URL from the Hyrax gem's config/hyrax.rb is stored in the descMetadata of the
      # curation_concern.  If that URL is valid in form, then it is used as a link.  If it is not valid, it is used as plain text.
      def attribute_value_to_html(value)
        begin
          parsed_uri = URI.parse(value)
        rescue URI::InvalidURIError
          nil
        end
        license_html = if parsed_uri.nil?
                         ERB::Util.h(value)
                       else
                         %(<a href=#{ERB::Util.h(value)}>#{Hyrax.config.license_service_class.new.label(value)}</a>)
                       end
        if microdata_value_attributes(field).present?
          "<span#{html_attributes(microdata_value_attributes(field))}>#{license_html}</span>"
        else
          license_html
        end
      end
    end
  end
end
