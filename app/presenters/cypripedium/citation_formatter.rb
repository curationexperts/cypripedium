# frozen_string_literal: true

module Cypripedium
  module CitationFormatter
    include Cypripedium::CitationTypeMapper

    def apa_citation
      citation_for('apa')
    end

    def chicago_citation
      custom_citation || citation_for('chicago-fullnote-bibliography')
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

    # Render :bibliographic_citation using markdown
    def custom_citation
      return unless bibliographic_citation

      renderer = Redcarpet::Render::HTML.new(escape_html: true)
      markdown = Redcarpet::Markdown.new(renderer, autolink: true)
      markdown.render(bibliographic_citation.join("\n\n")).html_safe # rubocop:disable Rails/OutputSafety
    end

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
        volume: volume_num,
        issue: issue_num,
        URL: url,
        publisher: publisher&.first || 'Federal Reserve Bank of Minneapolis, Minneapolis, MN',
        # 'publisher-place': 'Minneapolis, MN',
        # issued: date_for_citation, # Citation engine attempts to parse, fails on '2019 Winter'
        status: date_for_citation # same position as issued, but engine uses raw string
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
          'collection-number' => issue_num }
      else
        {} # always return a hash
      end
    end

    # Independent or supporting data
    def dataset_label
      return unless citation_type == 'dataset'

      if issue_num || title.first&.match(/additional file/i)
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

    # creation date (use deposit date if creation date is missing)
    # Extracts year and season or month
    # e.g. 2021-01-12  --> January 2021
    #      2019 Winter --> Winter 2019
    #      1968        --> 1968
    def date_for_citation
      return solr_document.date_uploaded&.year || 'no date' if date_created.blank?

      elements = date_created.first.match(/(?<year>\d{4})(-(?<month>\d{2})(-(?<day>\d{2}))?|\s*(?<season>[[:alpha:]]+))?/)
      return [elements[:season], elements[:year]].join(' ') if elements[:season]
      return [Date::MONTHNAMES[elements[:month].to_i], elements[:year]].join(' ') if elements[:month]
      elements[:year]
    end

    # Return the doi or other uri when present,
    # otherwise return a fallback url
    def url
      identifier.find { |id| id.match(/http|doi/) } || fallback_url
    end

    # Return the canonical url for the item
    def fallback_url
      Rails.application.routes.url_helpers.url_for([self, host_options])
    end

    # Extract the :host from the request if present, or set :only_path to true
    def host_options
      { host: request&.base_url, only_path: request&.base_url.nil? }
    end

    # Sanitize creator names
    # Remove dates like 1965- or 1935-2011
    # and initial expansions like F. T. (Fancis Thomas)
    # Examples ['Kocherlakota, Narayana Rao, 1963- ',  " \tAvenancio-León, Carlos\n",
    #            'Juster, F. Thomas (Francis Thomas), 1926-2019', 'Wang, Ping, 1957 December 5-']
    # returns ['Kocherlakota, Narayana Rao', 'Avenancio-León, Carlos', 'Juster, F. Thomas', 'Wang, Ping']
    def creators_for_citation
      alpha_creator.map { |name| name.gsub(/,\s*\d{4}.*|\([^)]*\)/, '') }
    end

    # Use the beginning of the series name up to the first parenthesis
    def series_for_citation
      series&.first&.split(' (')&.first
    end
  end
end
