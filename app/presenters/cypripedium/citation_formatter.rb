# frozen_string_literal: true

module Cypripedium
  module CitationFormatter
    def apa_citation
      citation_for('apa')
    end

    def chicago_citation
      citation_for('chicago-fullnote-bibliography')
    end

    def mla_citation
      citation_for('modern-language-association')
    end

    def citation_for(style)
      CiteProc::Processor.new(style: style, format: 'html').import(item).render(:bibliography, id: :item).first.html_safe # rubocop:disable Rails/OutputSafety
    rescue CiteProc::Error, TypeError, ArgumentError
      I18n.t('blacklight.search.pagination_info.no_items_found', entry_name: I18n.t('hyrax.base.citations.citations').downcase)
    end

    private

    # Return a CiteProc::Item constructed from the presenter metadata
    def item
      CiteProc::Item.new(citation_item)
    end

    # Hash of metadata required to construct citations
    # mpped to CSL variables
    # see https://docs.citationstyles.org/en/stable/specification.html#appendix-iv-variables
    # and https://github.com/citation-style-language/styles/blob/v1.0.2/chicago-fullnote-bibliography.csl
    def citation_item
      {
        id: :item,
        type: 'paper',
        title: title&.first,
        author: creators_for_citation,
        'collection-title': collection_for_citation,
        'collection-number': issue_number&.first,
        URL: url,
        publisher: 'Federal Reserve Bank of Minneapolis, Minneapolis, MN',
        # 'publisher-place': 'Minneapolis, MN',
        issued: date_created&.first.to_i
      }
    end

    # Return the doi or other uri when present,
    # otherwise return a fallback url
    def url
      @url ||= identifier.find { |id| id.match(/http|doi/) } || fallback_url
    end

    # Return the canonical url for the item
    def fallback_url
      Rails.application.routes.url_helpers.url_for([self, { host: request.base_url }])
    end

    # Remove dates like 1965- or 1935-2011
    # and initial expansions like F. T. (Fancis Thomas)
    def creators_for_citation
      creator.map { |name| name.gsub(/,\s*\d{4}-(\d{4})?|\([^)]*\)/, '') }
    end

    # Use the beginning of the series name up to the first parenthesis
    def collection_for_citation
      series&.first&.split(' (')&.first
    end
  end
end
