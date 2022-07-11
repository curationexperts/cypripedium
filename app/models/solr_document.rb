# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)
  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  Attributes.to_a.each do |term|
    define_method(term) do
      self[Solrizer.solr_name(term.to_s)]
    end
  end

  def alpha_creator
    self['alpha_creator_tesim']
  end

  def creator
    self['alpha_creator_tesim']
  end

  def series
    self['series_tesim']
  end

  def parent_collection
    self['member_of_collections_ssim']
  end

  def issue
    self['issue_number_tesim']
  end

  def doi
    self['identifier_tesim']
  end

  # Do content negotiation for AF models.

  use_extension(Hydra::ContentNegotiation)
end
