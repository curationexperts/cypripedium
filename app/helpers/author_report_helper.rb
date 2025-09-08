# frozen_string_literal: true

module AuthorReportHelper
  def author_formatter(row, key, start)
    case key
    when 'name'
      author_date_facet_link(row, start)
    else
      row[key]
    end
  end

  def author_date_facet_link(row, start)
    # pass the plain value back if the row does not have a valid creator id
    return row['name'] if row['id'].to_i.zero?

    link_to(row['name'], search_path(row, start))
  end

  # Returns a search link for date range + author facet
  # should be in the form https://researchdatabase.minneapolisfed.org/catalog?f%5Bcreator_sim%5D%5B%5D=Bianchi%2C+Javier&range%5Bdate_created_iti%5D%5Bbegin%5D=2022&range%5Bdate_created_iti%5D%5Bend%5D=2026
  def search_path(row, start)
    search_catalog_path(
      'f[creator_sim][]': row['name'],
      'range[date_created_iti][begin]': start.to_s[0..3],
      'range[date_created_iti][end]': Date.current.year,
      'sort': 'date_created_ssi desc'
    )
  end
end
