# frozen_string_literal: true

class BagJob < ActiveJobStatus::TrackableJob
  after_perform :after_bag_creation

  attr_reader :bag, :user

  def perform(work_ids:, time_stamp: Time.now.to_i, user:)
    @user = user
    @bag = Bag.new(work_ids: work_ids, time_stamp: time_stamp)
    @bag.create
  end

  private

    def after_bag_creation
      @user.send_message(@user, render_message(bag_file_name: @bag.bag_path.split('/').last.to_s, bag_files: @bag.bag.paths), "Your BagIt archive is ready")
      @bag.remove_bag
    end

    def render_message(bag_file_name:, bag_files:)
      ActionView::Base.new(Rails.configuration.paths['app/views']).render file: 'bag/_notification.html.erb',
                                                                          locals: { bag_file_name: bag_file_name,
                                                                                    bag_files: bag_files }
    end
end
