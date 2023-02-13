# frozen_string_literal: true

module UserCollectionsHelper
  include Hyrax::Renderers::ConfiguredMicrodata
  include Hyrax::CollectionsHelper

  def render_user_collection_list
    text = ""
    text += '<label class="user_collections_list" for="email" >Please type your email:</label><br>'
    text += '<input class="user_collections_list" type="text" name="email" id="email"><br><br>'

    text += '<label class="user_collections_list" for="email" >Please select from the list of collections:</label><br>'
    user_collections = load_user_collections
    user_collections.each do |collection|
      text += '<input type="checkbox" name="user_collections" class="form-check-input user_collections_list" id="' + collection['id'] + '" >'
      text += '<label class="form-check-input user_collections_list_label" for="' + collection['id'] + '">' + collection['term'] + '</label><br>'
    end
    # rubocop:disable Rails/OutputSafety
    text.html_safe
    # rubocop:enable Rails/OutputSafety
  rescue => e
    Rails.logger.error "An error came up while rendering collection license field: " + e.message
  end

  private

  def load_user_collections
    Qa::Authorities::Local.subauthority_for('user_collections').all
  end
end
