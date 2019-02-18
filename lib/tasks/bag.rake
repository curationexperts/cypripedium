# frozen_string_literal: true

namespace :bag do
  desc "Create a bag from a list of Publication IDs"
  task :create, [:work_ids] => :environment do |t, args|
    work_ids = args[:work_ids]
    extra_ids = args.extras
    all_ids = [work_ids] | extra_ids
    user = User.find(ENV['USER_ID'])
    BagJob.perform_now(work_ids: all_ids, user: user)
  end
end
