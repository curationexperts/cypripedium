# frozen_string_literal: true

# deploys to FRBM AWS Gov Cloud instances vis SSM
# defaults to staging environment
# To set a target environment, the instance must be tagged in Gov Cloud:
#   Project=rdb
#   Environment=prod | stage | qa | etc.
# Invoke the deploy command with the HOST_ENV variable specifying the desired environment, e.g.
#   HOST_ENV=prod bundle exec cap ssm deploy

require 'net/ssh/proxy/command'
set :stage, :production
set :host_env, -> { ENV['HOST_ENV'] || 'stage' }
set :instance_id, lambda {
  `aws ec2 describe-instances --region us-gov-east-1  --profile frbm-ssm \
                       --filters Name=tag-key,Values=Environment Name=tag-value,Values=#{fetch(:host_env)} Name=instance-state-name,Values=running \
                       Name=tag-key,Values=Project Name=tag-value,Values=rdb \
                       --query "Reservations[*].Instances[*].InstanceId" --output text`.chomp
}
server fetch(:instance_id), user: 'deploy', roles: [:web, :app, :db]
set :command, %(aws --profile frbm-ssm  ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p')
set :ssh_options,
  auth_methods: %w[publickey],
  forward_agent: true,
  proxy: Net::SSH::Proxy::Command.new(fetch(:command))

set :rails_env, 'production'
