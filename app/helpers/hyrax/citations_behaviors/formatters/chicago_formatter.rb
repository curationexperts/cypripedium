# frozen_string_literal: true

module Hyrax
  module CitationsBehaviors
    module Formatters
      class ChicagoFormatter < BaseFormatter
        include Hyrax::CitationsBehaviors::PublicationBehavior
        include Hyrax::CitationsBehaviors::TitleBehavior

        DEFAULT_DATASET_DB_NAME = 'Research Database'
        DEFAULT_URL_PREFIX = 'https://researchdatabase.minneapolisfed.org/concern/datasets/'

        class_attribute :default_logger
        self.default_logger = Rails.logger

        def format(work)
          text = ""
          resource_type = work.resource_type.at(0)
          authors_list = all_authors(work)
          pub_date = setup_pub_date(work)
          title = format_title(work.to_s)
          title_quoted = format_title_quoted(work.to_s);
          state = corporate_info work.corporate_name.at(0), 'state'
          city = corporate_info work.corporate_name.at(0), 'city'
          pub_info = setup_pub_info(work, false)
          author_info = format_authors(authors_list)
          author_info = "<span class=\"citation-author\">#{author_info}</span>" if author_info.present?
          related_url = work.related_url.at(0) if work.related_url.present?

          case resource_type
          when 'Book'
            text += author_info
            text += title
            text += corporate_address(city, state)
            pub_info[pub_info.length - 1] = ',' if pub_info.at(pub_info.length - 1) == '.'
            text += "#{whitewash(pub_info)}," if pub_info.present?
            text += " #{whitewash(pub_date)}." unless pub_date.nil?
          when 'Dataset'
            text += author_info
            text += title_quoted
            text += DEFAULT_DATASET_DB_NAME + ','
            if pub_info.present?
              pub_info[": "] = '';
              text += " #{whitewash(pub_info)},"
            end
            text += " #{whitewash(pub_date)}." unless pub_date.nil?
            text += ' ' + DEFAULT_URL_PREFIX + work.id + '.'
          when 'Conference Proceeding'
            text += author_info
            text += title_quoted
            series = ''
            if work.series.present? && work.series.at(0).present?
              series = work.series.at(0)
              series += " Conference" unless series.downcase.include?('conference')
              series = "Paper presented at the #{whitewash(series)},"
            end
            text += series if series.present?
            if pub_info.present?
              pub_info[": "] = '';
              text += " #{whitewash(pub_info)},"
            end
            text += corporate_address(city, state) + ','
            text += " #{whitewash(pub_date)}." unless pub_date.nil?
          when 'Part of Book'
            text += author_info
            text += title_quoted
            description = work.description
            info = process_part_of_book_description(description)
            if info.present?
              text += " In " + info["title"] + ", "
              text += "edited by " + info["authors"] + ". "
            end
            # Page number info is skipped here
            text += corporate_address(city, state)
            pub_info[pub_info.length - 1] = ',' if pub_info.at(pub_info.length - 1) == '.'
            text += "#{whitewash(pub_info)}," if pub_info.present?
            text += " #{whitewash(pub_date)}." unless pub_date.nil?
          when 'Software or Program Code'
            text += author_info
            text += " #{whitewash(work.to_s)}. "
            related_url_info = process_related_url(related_url)
            if !related_url_info.nil? && related_url_info.is_a?(Array) && related_url_info.length == 2
              text += "In \"#{related_url_info.at(1)}.\" " + related_url_info.at(0) + ", "
            elsif !related_url_info.nil?
              text += "In \"#{related_url_array}.\" "
            else
              logger.warn('Cannot parse the related URL info - Software or Program Code')
            end
            if pub_info.present?
              pub_info[": "] = '';
              text += " #{whitewash(pub_info)},"
            end
            text += " #{whitewash(pub_date)}." unless pub_date.nil?
          when 'Journal'
            text += author_info
            text += title_quoted
            collection = work.parent_collection
            text += " <i class=\"citation-title\">#{whitewash(collection.at(0))} </i>" if collection.present?
            issue = parse_issue work.issue
            text += issue
            text += " (#{whitewash(pub_date)})." unless pub_date.nil?
            text += " #{whitewash(work.doi.at(0))}." if work.doi.present?
          when 'Journal (without author)'
            text += 'Journal (without author)'
          when 'Article'
            text += author_info
            text += title_quoted
            collection = work.parent_collection
            text += " <i class=\"citation-title\">#{whitewash(collection.at(0))} </i>" if collection.present?
            issue = parse_issue work.issue
            text += issue
            text += " (#{whitewash(pub_date)})." unless pub_date.nil?
            text += " #{whitewash(work.doi.at(0))}." if work.doi.present?
          else
            text += ""
          end
          # rubocop:disable Rails/OutputSafety
          text.html_safe
          # rubocop:enable Rails/OutputSafety
        end

        def format_authors(authors_list = [])
          return '' if authors_list.blank?
          text = ''
          text += surname_first(authors_list.first) if authors_list.first
          authors_list[1..6].each_with_index do |author, index|
            text += if index + 2 == authors_list.length # we've skipped the first author
                      ", and #{given_name_first(author)}."
                    else
                      ", #{given_name_first(author)}"
                    end
          end
          text += " et al." if authors_list.length > 7
          # if for some reason the first author ended with a comma
          text = text.gsub(',,', ',')
          text += "." unless text.end_with?(".")
          whitewash(text)
        end
        # rubocop:enable Metrics/MethodLength

        def format_date(pub_date); end

        def format_title(title_info)
          return "" if title_info.blank?
          title_text = chicago_citation_title(title_info)
          title_text += '.' unless title_text.end_with?(".")
          title_text = whitewash(title_text)
          " <i class=\"citation-title\">#{title_text}</i>"
        end

        def format_title_quoted(title_info)
          return "" if title_info.blank?
          title_text = chicago_citation_title(title_info)
          title_text += '.' unless title_text.end_with?(".")
          title_text = '"' + whitewash(title_text) + '"&nbsp;'
          " <span class=\"citation-title\">#{title_text}</span>"
        end

        private

        def whitewash(text)
          Loofah.fragment(text.to_s).scrub!(:whitewash).to_s
        end

        def corporate_info(id, entry)
          Qa::Authorities::Local.subauthority_for('corporate_names').find(id).fetch(entry)
        end

        def corporate_address(city, state)
          text = ''
          if city.present?
            city_text = whitewash(city + ',')
            city_text = " <span class=\"citation-author\">#{city_text}</span>"
            text += city_text
          end
          return if state.blank?
          state_text = whitewash(state)
          state_text = " <span class=\"citation-author\">#{state_text}</span>"
          text + state_text
        end

        def parse_issue(issue_info)
          return "" if issue_info.blank?
          issue = issue_info.at(0).dup if issue_info.at(0).present?
          # An example of 'issue_number_tesim': "Vol. 1, No. 1", OR 'issue_number_tesim' can be just a number
          return whitewash(issue) if issue.match?(/\A\d+\z/)
          issue['Vol. '] = ''
          issue[' No. '] = ''
          issue_array = issue.strip.split(',')
          return whitewash(issue_array.at(0)) + ', no.' + whitewash(issue_array.at(1)) if !issue_array.nil? && issue_array.length == 2
          whitewash(issue)
        end

        def process_related_url(related_url)
          # sample related_url: "Staff Report 620: Star Wars at Central Banks,
          # https://doi.org/10.21034/sr.620\r\nStaff Report 621: Online Appendix: Star Wars at Central Banks,
          # https://doi.org/10.21034/sr.621"
          # need to split it to get the first element and then get the report name and doi
          # In the future, each related_url will contain one piece of info
          related_url_array = related_url.split(/(\r|\n|\r\n)+/)
          related_url = related_url_array.at(0) if related_url_array.present?
          related_url_array = related_url.split(",")
          related_url_array.at(0).split(": ")
        rescue => e
          logger.warn('Cannot parse related_url - Software or Program Code')
          logger.warn(e)
        end

        # The description assumes the format by: Chapter number, interized title, doi, authors. This might change in the future
        # Sample description: "Chapter 6 of [_Great Depressions of the Twentieth Century_](https://doi.org/10.21034/mo.9780978936006),
        # Timothy J. Kehoe and Edward C. Prescott, eds."

        def process_part_of_book_description(description)
          return nil if description.nil? || description.at(0).blank?
          description_text = description.at(0)
          pattern = /\(https:\/\/doi.org\/\d+\.\d+\/(\w+\.)+\d+\),\s/
          begin
            description_array = description_text.split("[_").at(1).split("_]")
            raise 'Error in parsing description - part of book' if description_array.nil? || !description_array.is_a?(Array) || description_array.length != 2
            title = description_array.at(0)
            doi = description_array.at(1).match(pattern)
            authors = description_array.at(1).gsub(pattern, '') if doi.present?
            raise 'Error in parsing title and authors from description - part of book' if title.blank? || authors.blank?
            authors[', eds.'] = ''
            { "title" => " <i class=\"citation-title\">#{whitewash(title)}</i>", "authors" => whitewash(authors) }
          rescue => e
            default_logger.warn(e.message)
          end
        end
      end
    end
  end
end