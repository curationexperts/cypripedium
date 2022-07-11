# frozen_string_literal: true

module Hyrax
  module CitationsBehaviors
    module Formatters
      class ChicagoFormatter < BaseFormatter
        include Hyrax::CitationsBehaviors::PublicationBehavior
        include Hyrax::CitationsBehaviors::TitleBehavior

        def format(work)
          puts "*****************"
          puts work.corporate_name
          puts ' using index ' + work.corporate_name.at(0)
          authorities = Qa::Authorities::Local.subauthority_for('corporate_names')
          corporate = authorities.find(work.corporate_name)
          puts corporate_info work.corporate_name.at(0), 'state'

          text = ""
          resource_type = work.resource_type.at(0)
          authors_list = all_authors(work)
          pub_date = setup_pub_date(work)
          title = format_title(work.to_s)
          state = corporate_info work.corporate_name.at(0), 'state'
          city = corporate_info work.corporate_name.at(0), 'city'
          pub_info = setup_pub_info(work, false)

          case resource_type
          when 'Book'
            text << format_authors(authors_list)
            text = "<span class=\"citation-author\">#{text}</span>" if text.present?
            text << title
            city_text = whitewash(city + ',')
            city_text = " <span class=\"citation-author\">#{city_text}</span>"
            text << city_text
            state_text = whitewash(state + ':')
            state_text = " <span class=\"citation-author\">#{state_text}</span>"
            text << state_text
            # text << (format_corporate_info city, 'city')
            # text << (format_corporate_info state, 'state')
            text << " #{whitewash(pub_info)}." if pub_info.present?
            text << " #{whitewash(pub_date)}." unless pub_date.nil?
          when 'Dataset'
            text << 'dataset'
          when 'Conference Proceeding'
            text << 'conference proceeding'
          when 'Part of Book'
            text << 'part of book'
          when 'Software or Program Code'
            text << 'software or program code'
          when 'Journal'
            text << 'journal'
          when 'Journal (without author)'
            text << 'Journal (without author)'
          when 'Article'
            text << 'article'
          else
            text << "unexpected"
          end
          text.html_safe
          # raw text
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

        private

        def whitewash(text)
          Loofah.fragment(text.to_s).scrub!(:whitewash).to_s
        end

        def corporate_info(id, entry)
          Qa::Authorities::Local.subauthority_for('corporate_names').find(id).fetch(entry)
        end
      end
    end
  end
end
