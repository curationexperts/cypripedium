# frozen_string_literal: true

class CreatorNames
  class << self
    def normalized_names(ids)
      return [] if ids.blank?
      names = Creator.where(id: ids.to_a).pluck(:display_name)

      # This DB query silently drops any invalid ids, which shouldn't be possible under normal circumstances.
      # This gives us a bread-crumb if something unusual is going on.
      Hyrax.logger.error "Invalid creator ID lookup in: #{ids}" if names.size != ids.size

      normalized = names.map { |name| normalize(name) }
      normalized.sort_by(&:downcase)
    end

    # Sanitize creator names
    # Remove dates like 1965- or 1935-2011
    # and initial expansions like F. T. (Fancis Thomas)
    # Examples:
    #   'Kocherlakota, Narayana Rao, 1963- ' --> 'Kocherlakota, Narayana Rao'
    #   " \tAvenancio-León, Carlos\n" --> 'Avenancio-León, Carlos'
    #   'Juster, F. Thomas (Francis Thomas), 1926-2019' --> 'Juster, F. Thomas'
    #   'Wang, Ping, 1957 December 5-' --> 'Wang, Ping'
    def normalize(name)
      return 'invalid_name' unless name.is_a?(String)
      name.gsub(/,\s*\d{4}.*|\s*\([^)]*\)|\A\s+|\s+\z/, '')
    end
  end
end
