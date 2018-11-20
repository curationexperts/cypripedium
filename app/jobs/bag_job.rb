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
      bag_file_name = @bag.bag_path.split.last.to_s
      @user.send_message(@user,
                         "Your bag has been created and can be downloaded <a href='/bag/download/#{bag_file_name}'>here</a>.",
                         "Your BagIt archive is ready")
    end
end
