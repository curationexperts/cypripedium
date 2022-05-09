# frozen_string_literal: true

# deploys to FRBM AWS production
require 'net/ssh/proxy/command'
set :stage, :production
set :instance_id, lambda {
  `aws ec2 describe-instances --region us-gov-east-1  --profile frbm-ssm\
                       --filters Name=tag-key,Values=Environment Name=tag-value,Values=prod Name=instance-state-name,Values=running \
                       --query "Reservations[*].Instances[*].InstanceId" --output text`.chomp
}
server fetch(:instance_id), user: 'deploy', roles: [:web, :app, :db]
set :command, %(aws --profile frbm-ssm  ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p')
set :ssh_options,
  auth_methods: %w[publickey],
  forward_agent: true,
  proxy: Net::SSH::Proxy::Command.new(fetch(:command))

set :rails_env, 'production'
