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
    if user && !user.persisted? && new_user = User.find_by(email: user.email)
      self.user = new_user
    elsif user
      user.save!
      self.user = user
    end
  end
end
