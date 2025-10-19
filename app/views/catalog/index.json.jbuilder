# frozen_string_literal: true

json.response do
  json.docs @presenter.documents
  json.pages @presenter.pagination_info
end
