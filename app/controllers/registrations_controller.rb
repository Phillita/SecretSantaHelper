# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  prepend_after_action :send_confirmation_for_existing_user, only: :create

  private

  # overriding the original build resource that devise uses so that I can find a user already in the database
  # otherwise continue with the new user
  def build_resource(hash = nil)
    self.resource = resource_class.find_by(email: hash[:email]) if resource_class.exists?(email: hash[:email])
    self.resource ||= resource_class.new_with_session(hash || {}, session)
    self.resource.attributes = (hash || {}).merge(guest: nil)
    self.resource = resource_class.new_with_session(hash || {}, session) unless resource.valid?
  end

  def send_confirmation_for_existing_user
    return if resource.new_record? || !resource.valid? || resource.confirmed?
    resource.send_confirmation_instructions
  end
end
