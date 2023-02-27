# frozen_string_literal: true

module UserCollectionsHelper
  include Hyrax::Renderers::ConfiguredMicrodata
  include Hyrax::CollectionsHelper

  def render_user_collection_list
    text = ""
    text += '<label class="user_collections_list" for="email" >Please type your email:</label><br>'
    text += '<input class="user_collections_list" type="text" name="email" id="email" size="40">&nbsp;&nbsp;&nbsp;<br><br>'
    text += '<button class="user_collections_list" id="user_subscriptions_search">'
    text += '<span class="glyphicon glyphicon-search" aria-hidden="true"></span>'
    text += '</button>&nbsp;&nbsp;'
    text += '<label for="user_subscriptions_search">Find your current subscriptions:</label><br><br>'
    text += '<div class="user_collections_list" id="subscription_list_div"><ul id="subscription_list" style="list-style-type:square"></ul></div>'
    text += '<br>'

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
