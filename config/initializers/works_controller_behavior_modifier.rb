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
      if all_collections.present? && all_collections.length.positive?
        all_collections.each do |user_collection|
          emails.push(user_collection.email)
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
end
