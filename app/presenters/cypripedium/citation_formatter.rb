# frozen_string_literal: true

module Cypripedium
  module CitationFormatter
    include Cypripedium::CitationTypeMapper

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
      @item ||= CiteProc::Item.new(citation_item)
    end

    # Hash of metadata required to construct citations
    # mpped to CSL variables
    # see https://docs.citationstyles.org/en/stable/specification.html#appendix-iv-variables
    # and https://github.com/citation-style-language/styles/blob/v1.0.2/chicago-fullnote-bibliography.csl
    def citation_item
      {
        id: :item,
        type: citation_type,
        title: title&.first,
        author: creators_for_citation,
        volume: volume_number_for_citation,
        issue: issue_number_for_citation,
        URL: url,
        publisher: publisher&.first || 'Federal Reserve Bank of Minneapolis, Minneapolis, MN',
        # 'publisher-place': 'Minneapolis, MN',
        issued: date_for_citation
      }.merge(type_specific_data)
    end

    def type_specific_data
      case citation_type
      when 'article-journal'
        # container-title gets italicized, collection-title does not
        { 'container-title' => series_for_citation }
      when 'paper-conference'
        { 'collection-title' => conference_details,
          'publisher' => nil } # publisher is inlcuded in comma separated sponsor info in conference details instead
      when 'manuscript', 'dataset'
        { 'collection-title' => [dataset_label, series_for_citation].compact.join('. '),
          'collection-number' => issue_number&.first }
      else
        {} # always return a hash
      end
    end

    # Independent or supporting data
    def dataset_label
      return unless citation_type == 'dataset'

      if issue_number || title.first.match(/additional file/i)
        'Supporting Data'
      else
        'Research Database'
      end
    end

    # Name, sponsor, and place of conference
    def conference_details
      ["Paper presented at the #{conference_name}",
       'Federal Reserve Bank of Minneapolis',
       'Minneapolis, MN'].join(', ')
    end

    # Return a conference name based on the series name
    def conference_name
      return series_for_citation if series&.first&.match?(/[Cc]onference/)

      "#{series_for_citation} conference"
    end

    # creations date or deposit date if creation date is missing
    def date_for_citation
      return Date.parse(date_uploaded).year if date_created.blank?

      date_created.first.to_i
    end

    # Return the doi or other uri when present,
    # otherwise return a fallback url
    def url
      identifier.find { |id| id.match(/http|doi/) } || fallback_url
    end

    # Return the canonical url for the item
    def fallback_url
      Rails.application.routes.url_helpers.url_for([self, { host: request.base_url }])
    end

    # Sanitize creator names
    # Remove dates like 1965- or 1935-2011
    # and initial expansions like F. T. (Fancis Thomas)
    # Examples ['Kocherlakota, Narayana Rao, 1963- ',  " \tAvenancio-León, Carlos\n",
    #            'Juster, F. Thomas (Francis Thomas), 1926-2019', 'Wang, Ping, 1957 December 5-']
    # returns ['Kocherlakota, Narayana Rao', 'Avenancio-León, Carlos', 'Juster, F. Thomas', 'Wang, Ping']
    def creators_for_citation
      creator.map { |name| name.gsub(/,\s*\d{4}.*|\([^)]*\)/, '') }
    end

    # Use the beginning of the series name up to the first parenthesis
    def series_for_citation
      series&.first&.split(' (')&.first
    end

    def issue_number_for_citation
      parse_issue_and_volume[:issue]
    end

    def volume_number_for_citation
      parse_issue_and_volume[:volume]
    end

    # extract alpha-numeric issue and volume number from issue field
    # sample data can appear as
    #   Vol. 16, No. 1
    #   vol.10 no.36
    #   no. 41
    #   no.93
    #   130
    #   081
    #   "vol.8 no.59 "
    #   no. 54A
    def parse_issue_and_volume
      return { issue: nil, volume: nil } unless issue_number

      @parse_issue_and_volume ||= issue_number.first.match(/^(v(ol)?\.?\s*(?<volume>\w+),?\s*)?(no\.?)?\s*(?<issue>\w+)/i)
    end
  end
end
