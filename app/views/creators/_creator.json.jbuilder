# frozen_string_literal: true
json.extract! creator, :id, :display_name, :alternate_names, :group, :repec, :viaf, :active_creator, :created_at, :updated_at
json.url creator_url(creator, format: :json)
