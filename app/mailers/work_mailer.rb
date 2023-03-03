# frozen_string_literal: true

class WorkMailer < ApplicationMailer
  def new_work_email(work = {}, emails)
    @work = work
    mail(
      from: "tao.zhao@mpls.frb.org",
      to: emails,
      subject: "New work published at Research Database: #{work[:title]}"
    )
  end
end
