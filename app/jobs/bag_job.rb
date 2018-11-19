# frozen_string_literal: true

class BagJob < ActiveJobStatus::TrackableJob
  def perform(work_ids:, time_stamp: Time.now.to_i)
    bag = Bag.new(work_ids: work_ids, time_stamp: time_stamp)
    bag.create
  end
end
