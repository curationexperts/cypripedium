# frozen_string_literal: true
###
# This class creates and returns a collection object
# It will first look for a Collection with the title it is given
# if it finds one, it uses that collection. If it doesn't find one
# it will create a new collection with the given title.
module Contentdm
  class CollectionBuilder
    ##
    # @param title [String]
    def initialize(title)
      @title = title
    end

    ##
    # @return [ActiveFedora::Base]
    def find_or_create
      collection = ::Collection.where(title_tesim: @title).first
      collection ||= ::Collection.new(title: @title, collection_type: Hyrax::CollectionType.find_or_create_default_collection_type)

      collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      if collection.id
        Contentdm::Log.new("Found collection: #{@title[0]} with ID: #{collection.id}", 'info')
      else
        Contentdm::Log.new("Creating collection: #{@title[0]}", 'info')
      end
      return collection if collection.save! != false
    end
  end
end
