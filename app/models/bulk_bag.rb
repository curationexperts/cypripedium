# frozen_string_literal: true

# A class for creating multiple bags from a list of Work ids
class BulkBag
  # @param ids [Array<String>] an array of IDs (as strings) that will be bagged
  def initialize(ids:)
    @ids = ids
  end

  def create
    @ids.each do |id|
      bag = Bag.new(work_id: id, time_stamp: Time.now.to_i)
      bag.create
    end
  end
end
