# frozen_string_literal: true
class BagJob < ApplicationJob
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
    <<~NOTICE.html_safe # rubocop:disable Rails/OutputSafety
      <div>
        Your bag containing #{work_count} #{'work'.pluralize(work_count)},#{' '}
        including #{bag_files.first}, is available for download at#{' '}
        <a data-turbolinks='false' href='/bag/#{bag_file_name}.#{bag_format}'>#{bag_file_name}.#{bag_format}</a>
      </div>
    NOTICE
  end

  def render_error_message(error:)
    <<~ERROR.html_safe # rubocop:disable Rails/OutputSafety
      There was an error starting your bag job:
      <pre>
        #{error}
      </pre>
    ERROR
  end
end
