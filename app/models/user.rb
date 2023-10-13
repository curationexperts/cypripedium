# frozen_string_literal: true

class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # Include default devise modules.  For more info, see:
  # https://github.com/plataformatec/devise/blob/master/README.md
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def add_role(name)
    role = Role.find_by(name: name)
    role = Role.create(name: name) if role.nil?
    role.users << self
    role.save
    reload
  end

  def remove_role(name)
    role = Role.find_by(name: name)
    role.users.delete(self) if role&.users && role.users.include?(self)
    reload
  end
end
