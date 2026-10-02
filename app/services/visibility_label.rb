# frozen_string_literal: true

# Plain-text labels for Hyrax visibility values.
# Matches the UI text of Hyrax::PermissionBadge (e.g. "Public", "FRBM", "Private").
#
# Use in non-view code that needs the label as a string, such as CSV
# exports built in background jobs. In views, use the Hyrax::PermissionBadge
# helper instead.
#
# Labels are read once from Hyrax::PermissionBadge, in the default I18n
# locale, and cached for the life of the process.
#
# @see Hyrax::PermissionBadge
module VisibilityLabel
  def self.for(visibility) = labels[visibility.to_s]

  # Returns the UI text used for a Hyrax visibility value.
  #
  # @param visibility [String, Symbol, nil] a raw visibility value,
  #   e.g. a work's or file set's +visibility+
  # @return [String, nil] the frozen label, or nil if the value is unknown
  #
  # @example
  #   VisibilityLabel.for('authenticated') #=> "FRBM"
  #   VisibilityLabel.for(:open)           #=> "Public"
  #   VisibilityLabel.for('bogus')         #=> nil
  # @note The "authenticated" label is Hyrax::Institution.name (hyrax.institution_name).
  def self.labels
    @labels ||= Hyrax::PermissionBadge::VISIBILITY_LABEL_CLASS.keys.map(&:to_s).index_with do |key|
      Nokogiri::HTML5.fragment(Hyrax::PermissionBadge.new(key).render).text.freeze
    end.freeze
  end

  private_class_method :labels
end
