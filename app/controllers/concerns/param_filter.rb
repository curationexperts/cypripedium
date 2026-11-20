# frozen_string_literal: true

module ParamFilter
  extend ActiveSupport::Concern

  # The two longest parameter names we could identify were 'sub_collection_page' and 'member_of_collection_ssim'.
  # We also need to allow for dotted names like 'facet.page', and negated facet names like '-creator_sim'.
  MAX_NAME_LENGTH = 40
  VALID_NAME = /\A-?\w+(\.\w+)?\z/
  UNSAFE_VALUE = /<[a-z\/!?]/i # i.e. starts like an HTML tag

  included do
    prepend_before_action :reject_invalid_params
  end

  private

  def reject_invalid_params
    bad = invalid_param(request.query_parameters)
    return unless bad

    logger.warn("Rejected request: invalid parameter #{bad.truncate(MAX_NAME_LENGTH).inspect}")
    head :bad_request
  end

  def invalid_param(query_params)
    case query_params
    when Hash
      query_params.keys.find { |name| invalid_name?(name) } || invalid_param(query_params.values)
    when Array
      query_params.filter_map { |item| invalid_param(item) }.first
    else
      query_params if invalid_value?(query_params)
    end
  end

  def invalid_name?(name)
    !VALID_NAME.match?(name) || name.length > MAX_NAME_LENGTH
  end

  def invalid_value?(value)
    UNSAFE_VALUE.match?(value)
  end
end
