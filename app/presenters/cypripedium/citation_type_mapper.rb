# frozen_string_literal: true

module Cypripedium
  module CitationTypeMapper
    private

    # Map resource_type to CSL citation types
    # for a list of valid CSL types, see https://docs.citationstyles.org/en/stable/specification.html#appendix-iii-types
    MAPPER =
      { 'Article' => 'article-journal',
        'Conference Proceeding' => 'paper-conference',
        'Dataset' => 'dataset',
        'Other' => 'dataset',
        'Report' => 'article-journal',
        'Research Paper' => 'manuscript',
        'Software or Program Code' => 'dataset' }.freeze

    def citation_type
      MAPPER[resource_type&.first] || 'dataset'
    end
  end
end
