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

  # 2025-05-10 MHB - we're currently indexing all name variants into the creator field, so
  # creator might inlcude multiple variants for the same person. Using alpha_creator
  # in the presenter ensures that we only display the preferred name, and that names are sorted in
  # alphbetical order
  def creator
    alpha_creator
  end
end
