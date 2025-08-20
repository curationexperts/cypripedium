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

  def search_path(row, start)
    search_catalog_path(
      'f[creator_sim][]': row['name'],
      'range[date_created_iti][begin]': start,
      'range[date_created_iti][end]': Date.current.year,
      'sort': 'date_created_ssi desc'
    )
  end
end
