# frozen_string_literal: true

class WorkMailer < ApplicationMailer
  def new_work_email(work = {})
    @work = work
    mail(
      from: "tao.zhao@mpls.frb.org",
      to: "tao.zhao@mpls.frb.org",
      subject: "New work published at Research Database: #{work[:title]}"
    )
  end
end
