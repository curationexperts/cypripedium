# frozen_string_literal: true

class CypripediumWorkPresenter < Hyrax::WorkShowPresenter
  Attributes.to_a.each { |term| delegate term, to: :solr_document }
  delegate :alpha_creator, to: :solr_document

  def work_zip
    WorkZip.latest(id).first || WorkZip.new(work_id: id)
  end
end
