# frozen_string_literal: true

module MetadataHelper
  def get_author_name_list(work)
    authors = work['alpha_creator_tesim'] ? work['alpha_creator_tesim'] : []
    return [] if authors.blank?
    authors_list = authors.uniq.compact
    authors_list.map! do |author|
      parse_author(author)
    end
    authors_list
  end

  # This is to handle names like 'Boot, Arnoud W. A. (Willem Alexander), 1960-'
  def parse_author(author)
    author = author.sub(/,\s*\d{4}-$/, '')
    author.sub(/\s*\(.+\)/, '')
  end

  def format_authors(authors_list = [])
    return '' if authors_list.blank?
    text = ''
    text += surname_first(authors_list.first) if authors_list.first
    authors_list[1..6].each_with_index do |author, index|
      text += if index + 2 == authors_list.length # we've skipped the first author
                ", and #{chicago_citation_given_name_first(author)}."
              else
                ", #{chicago_citation_given_name_first(author)}"
              end
    end
    text += " et al." if authors_list.length > 7
    # if for some reason the first author ended with a comma
    text = text.gsub(',,', ',')
    text += "." unless text.end_with?(".")
    whitewash(text)
  end

  def get_formated_author_names(work)
    author_list = get_author_name_list work
    return '' if author_list.blank?
    format_authors(author_list)
  end

  # Rewrite the code to avoid the method clean_end_punctuation to remove the last '.' at the end of name abbreviation:
  # e.g. Daivds, John W. will be shown as John W Davids, with the '.' after 'W' removed.
  def chicago_citation_given_name_first(name)
    name = name[0, name.length - 1] if name && ([",", ":", ";", "/"].include? name[-1, 1])
    return name unless name.include?(',')
    temp_name = name.split(/,\s*/)
    temp_name.last + " " + temp_name.first
  end

  def whitewash(text)
    Loofah.fragment(text.to_s).scrub!(:whitewash).to_s
  end

  def get_series_from_work(work, index = 0)
    return '' if work[:series_tesim].blank? || work[:series_tesim][0].blank?
    return work[:series_tesim][0] unless index.present? && index.integer?
    work[:series_tesim][index]
  end

  def get_date_created_from_work(work, index = 0)
    return '' if work[:date_created_tesim].blank? || work[:date_created_tesim][0].blank?
    return work[:date_created_tesim][0] unless index.present? && index.integer?
    work[:date_created_tesim][index]
  end
end
