# frozen_string_literal: true

class Ability
  include Hydra::Ability

  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end
    can [:edit, :update, :create, :index, :show], Creator if current_user.admin?
    can [:index, :show], Creator if current_user
    can [:index], UserCollection if current_user.admin?
    can [:create, :show, :destroy], UserCollection if current_user
    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end
end
