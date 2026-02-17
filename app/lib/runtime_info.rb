# frozen_string_literal: true
require 'aws-sdk-core'
require 'aws-sdk-core/ec2_metadata'

class RuntimeInfo
  class << self
    def badge
      @badge ||=
        if environment == 'EC2:Production'
          ''
        else
          "<div id=\"environment_badge\">#{environment.titleize}</div>".html_safe # rubocop:disable Rails/OutputSafety
        end
    end

    def environment
      @environment ||=
        case aws_info
        when /stag/
          'staging'
        when /prod/
          'EC2:Production'
        when /q/
          'quality assurance'
        else
          aws_info || Rails.env
        end
    end

    def aws_info
      @aws_info ||=
        begin
          return nil unless ec2?
          metadata_client = Aws::EC2Metadata.new
          metadata_client.get('/latest/meta-data/tags/instance/Environment')
        rescue Errno::EHOSTDOWN, Net::OpenTimeout, Errno::EHOSTUNREACH
          # just return nil without an exception
        end
    end

    def ec2?
      @ec2 ||= File.exist?('/sys/devices/virtual/dmi/id/bios_vendor') &&
               File.read('/sys/devices/virtual/dmi/id/bios_vendor').match(/EC2/)
    end
  end
end
