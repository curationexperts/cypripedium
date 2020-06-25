# frozen_string_literal: true
class BagJob < ActiveJobStatus::TrackableJob
  rescue_from(StandardError) do |exception|
    @bag&.remove
    @user.send_message(@user, render_error_message(error: exception), "Error creating your BagIt Archive")
  end

  after_perform :after_bag_creation

  attr_reader :bag, :user, :compression, :work_ids, :time_stamp

  def perform(work_ids:, time_stamp: Time.now.to_i, user:, compression:)
    @user = user
    @compression = compression
    @work_ids = work_ids
    @time_stamp = time_stamp
    initialize_bag
  end

  private

  def initialize_bag
    case @compression
    when 'zip'
      @bag = Hyrax::ZipBag.new(work_ids: @work_ids, time_stamp: @time_stamp)
    when 'tar'
      @bag = Hyrax::TarBag.new(work_ids: @work_ids, time_stamp: @time_stamp)
    end
    @bag.create
  end

  def after_bag_creation
    @user.send_message(@user, render_message(bag_file_name: @bag.bag_path.split('/').last.to_s,
                                             bag_files: @bag.bag.paths, bag_format: @compression,
                                             work_count: @bag.work_count), "Your BagIt archive is ready")
    @bag.remove
  end

  def render_message(bag_file_name:, bag_files:, bag_format:, work_count:)
    ActionView::Base.new(Rails.configuration.paths['app/views']).render file: 'bag/_notification.html.erb',
                                                                        locals: { bag_file_name: bag_file_name,
                                                                                  bag_files: bag_files, bag_file_format: bag_format,
                                                                                  work_count: work_count }
  end

  def render_error_message(error:)
    ActionView::Base.new(Rails.configuration.paths['app/views']).render file: 'bag/_error_notification.html.erb',
                                                                        locals: { error: error }
  end
end
