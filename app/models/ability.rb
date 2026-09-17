# frozen_string_literal: true

class Ability
  include Hydra::Ability

  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    # All Users
    return unless current_user
    can [:index, :show], Creator
    can [:download], Export, visibility: Export.visibilities[:open], format: Export.formats[:zip]

    return unless current_user.persisted?
    can [:download], Export, visibility: Export.visibilities[:authenticated], format: Export.formats[:zip]

    # Restricted to Admins
    return unless current_user.admin?
    can [:index], :reports
    can [:edit, :update, :create, :index, :show], Creator
    can [:index, :confirm, :create, :destroy, :download, :items], Export
  end
end
