# frozen_string_literal: true

module CollectionLicenseAttributeRendererHelper
  include Hyrax::Renderers::ConfiguredMicrodata
  def render_collection_license_attribute(presenter)
    label = collection_metadata_label(presenter, :license)
    text = ""
    text += "<dt>#{label}</dt>"
    value = presenter.license.at(0)
    parsed_uri = URI.parse(value)
    license_html = if parsed_uri.nil?
                     ERB::Util.h(value)
                   else
                     %(<a href=#{ERB::Util.h(value)} target="_blank">#{Hyrax.config.license_service_class.new.label(value)}</a>)
                   end
    license_html = "<span#{license_attributes(microdata_value_attributes(:license))}>#{license_html}</span>" if microdata_value_attributes(:license).present?
    text += "<dd>#{license_html}</dd>"
    # rubocop:disable Rails/OutputSafety
    text.html_safe
    # rubocop:enable Rails/OutputSafety
  rescue => e
    Rails.logger.error "An error came up while rendering collection license field: " + e.message
  end

  private

  def license_attributes(attributes)
    attributes.map do |key, value|
      value_set = value.present? ? %(="#{value}") : nil
      " #{key}#{value_set}"
    end.join
  end
end
