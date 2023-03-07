# frozen_string_literal: true
require 'user_collections_helper'

Hyrax::WorksControllerBehavior.module_eval do
  # Added the email sending method call when new work published
  def after_create_response
    respond_to do |wants|
      work = { title: curation_concern.first_title, id: curation_concern.id, username: current_user.name, uri: request.host_with_port }
      all_collection_records = UserCollection.all
      all_collections = all_collection_records.to_a if all_collection_records.present?
      emails = []
      collection_id = collection_id_from_params
      if collection_id.present?
        collection = Collection.find(collection_id)
        collection_title = collection.title.first if collection.present?
        user_collection_id = get_user_collection_id(collection_title)
        if all_collections.present? && user_collection_id.present?
          all_collections.each do |user_collection|
            emails.push(user_collection.email) if user_collection.collections.include? user_collection_id
          end
        end
      end

      WorkMailer.new_work_email(work, emails).deliver if emails.length.positive?

      wants.html do
        # Calling `#t` in a controller context does not mark _html keys as html_safe
        flash[:notice] = view_context.t('hyrax.works.create.after_create_html', application_name: view_context.application_name)
        redirect_to [main_app, curation_concern]
      end
      wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
    end
  end

  private

  def collection_id_from_params
    params_curation_concern = params[hash_key_for_curation_concern]
    collection_id = params_curation_concern[:member_of_collection_ids][0] if params_curation_concern[:member_of_collection_ids].present?
    return if collection_id.present?
    attributes = params_curation_concern[:member_of_collections_attributes]
    collection_ids = attributes['0'] if attributes.present?
    return collection_ids['id'] if collection_ids.present?
  end

  def collection_id_array(user_collection)
    collection_string = user_collection.collections
    collection_string.split(" ; ") if collection_string.present?
  end

  def get_user_collection_id(collection_name)
    config_user_collections = Qa::Authorities::Local.subauthority_for('user_collections').all
    config_user_collections.each do |config_user_collection|
      return config_user_collection.fetch('id') if config_user_collection.fetch('term') == collection_name
    end
  end
end
