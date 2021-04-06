# frozen_string_literal: true
namespace :cypripedium do
  desc "Setup standard admin login account"
  task standard_users_setup: :environment do
    if ENV["RAILS_ENV"] != "production"
      create_first_admin_user
    else
      puts "Rails running in production mode, not creating first user or first admin"
    end
  end

  def create_first_admin_user
    u = User.find_or_create_by(email: "admin@testdomain.com")
    u.display_name = "Test Admin"
    u.password = "password"
    u.password_confirmation = "password"
    u.save!
    admin_role = Role.find_or_create_by(name: 'admin')
    admin_role.users << u
    admin_role.save!
  end
end
