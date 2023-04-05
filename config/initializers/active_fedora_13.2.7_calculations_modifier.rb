# frozen_string_literal: true

ActiveFedora::Calculations.module_eval do
  def get(*args)
    return apply_finder_options(args.first).count if args.any?
    opts = {}
    opts[:rows] = limit_value if limit_value
    opts[:sort] = order_values if order_values

    # SolrService.count(create_query(where_values))
    query = create_query(where_values)
    ActiveFedora::SolrService.query(query, { rows: 1000 })
  end
end
