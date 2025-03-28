# frozen_string_literal: true

module RDF
  module Markdown
    ##
    # A Mardownliteral
    #
    # @example Initializing an EDTF literal with {RDF::Literal}
    #    RDF::Literal(my_markdown_string, datatype: RDF::Markdown::Literal::DATATYPE)
    #
    class Literal < RDF::Literal
      DATATYPE = RDF::URI('http://ns.ontowiki.net/SysOnt/Markdown')
      ##
      # We punt on a Markdown grammar and accept any string the user throws us as
      # valid. If your markdown parser barfs, that's your problem.
      #
      # @see http://roopc.net/posts/2014/markdown-cfg/
      GRAMMAR = %r{.*}

      # support ActiveJob serialization
      include GlobalID::Identification

      def self.find(id)
        new(id)
      end

      def id
        value
      end
    end
  end
end
