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

  Cypripedium::Metadata.attribute_names.each do |term|
    define_method(term) do
      self[Solrizer.solr_name(term.to_s)]
    end
  end

  def alpha_creator
    Array(self['alpha_creator_tesim'])
  end

  # Issue number as a scalar integer
  # Note: the `issue_number` field holds both the volume and issue number concatenated as text
  def issue_num
    self['issue_number_isi']
  end

  # Volume number as a scalar integer
  def volume_num
    self['volume_number_isi']
  end

  # Do content negotiation for AF models.

  use_extension(Hydra::ContentNegotiation)
end
