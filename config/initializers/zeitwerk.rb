# frozen_string_literal: true

Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "rdf_xml_service" => "RdfXmlService",
    "rdf" => "RDF"
  )
end
