# frozen_string_literal: true

class Participant < ApplicationRecord
  include ArelHelpers::ArelTable

  belongs_to :participantable, polymorphic: true
  belongs_to :user, autosave: true

  validates :user, :participantable, presence: true

  accepts_nested_attributes_for :user, reject_if: :all_blank

  delegate :name, :email, to: :user

  def autosave_associated_records_for_user
    return if user.nil?
    if user && !user.persisted? && User.exists?(email: user.email)
      new_user = User.find_by(email: user.email)
      new_user.update_attributes(user.slice(:first_name, :last_name))
      self.user = new_user
    elsif user
      user.save!
      self.user = user
    end
  end

  def user_attributes=(attributes)
    self.user = User.find(attributes['id']) if attributes['id'].present?
    super
  end
end
