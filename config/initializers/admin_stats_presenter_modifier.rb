# frozen_string_literal: true

Hyrax::AdminStatsPresenter.class_eval do
  def date_filter_string
    if start_date.blank?
      pre_quarter = Time.zone.now - 3.months
      quarter_start_date = pre_quarter.beginning_of_quarter
      quarter_end_date = pre_quarter.end_of_quarter
      "#{quarter_start_date.to_date.to_formatted_s(:standard)} to #{quarter_end_date.to_date.to_formatted_s(:standard)}}"
    elsif end_date.blank?
      "#{start_date.to_date.to_formatted_s(:standard)} to #{Date.current.to_formatted_s(:standard)}"
    else
      "#{start_date.to_date.to_formatted_s(:standard)} to #{end_date.to_date.to_formatted_s(:standard)}"
    end
  end
end
