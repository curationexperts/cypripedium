# frozen_string_literal: true

class ReleaseInfo
  class << self
    def sha
      @sha ||=
        if capistrano?
          revisions[3].gsub(/\)$/, '')
        elsif dev_test?
          `git rev-parse HEAD`.chomp
        else
          "Unknown SHA"
        end
    end

    def branch
      @branch ||=
        if capistrano?
          revisions[1]
        elsif dev_test?
          `git rev-parse --abbrev-ref HEAD`.chomp
        else
          "Unknown branch"
        end
    end

    def deployment_timestamp
      @deployment_timestamp =
        if capistrano?
          deployed = revisions[7]
          Date.parse(deployed).strftime("%d %B %Y")
        else
          "Not in deployed environment"
        end
    end

    def capistrano?
      @capistrano ||= Rails.env.production? && File.exist?('/opt/cypripedium/revisions.log')
    end

    def dev_test?
      @dev_test ||= Rails.env.development? || Rails.env.test?
    end

    def revisions
      @revisions ||= `tail -1 /opt/cypripedium/revisions.log`.chomp.split(" ")
    end
  end
end
