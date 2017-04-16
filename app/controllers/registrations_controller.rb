# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    # add custom create logic here
    if User.exists?(email: creation_params[:email])
      resource = User.find_by(email: creation_params[:email])
      resource.update_attributes(creation_params.merge(guest: nil))

      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      super
    end
  end

  def update
    super
  end

  private

  def creation_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
  end
end
