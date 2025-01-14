# frozen_string_literal: true

class CypripediumWorkPresenter < Hyrax::WorkShowPresenter
  include Cypripedium::CitationFormatter

  Cypripedium::Metadata.attribute_names.each { |term| delegate term, to: :solr_document }
  delegate :alpha_creator, to: :solr_document
  delegate :issue_num, to: :solr_document
  delegate :volume_num, to: :solr_document

  def work_zip
    WorkZip.latest(id).first || WorkZip.new(work_id: id)
  end
end
