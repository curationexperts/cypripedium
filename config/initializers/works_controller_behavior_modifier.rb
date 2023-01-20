# frozen_string_literal: true

Hyrax::WorksControllerBehavior.module_eval do
  # Added the email sending method call when new work published
  def after_create_response
    respond_to do |wants|
      work = { title: curation_concern.first_title, id: curation_concern.id, username: current_user.name, uri: request.host_with_port }
      WorkMailer.new_work_email(work).deliver
      wants.html do
        # Calling `#t` in a controller context does not mark _html keys as html_safe
        flash[:notice] = view_context.t('hyrax.works.create.after_create_html', application_name: view_context.application_name)
        redirect_to [main_app, curation_concern]
      end
      wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
    end
  end
end
