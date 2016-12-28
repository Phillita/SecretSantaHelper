class Participant < ActiveRecord::Base
  include ArelHelpers::ArelTable

  belongs_to :participantable, polymorphic: true
  belongs_to :user, autosave: true

  validates :user, :participantable, presence: true

  accepts_nested_attributes_for :user, reject_if: :all_blank

  delegate :name, :email, to: :user

  def autosave_associated_records_for_user
    return if user.nil?
    # Find or create the author by name
    if user && new_user = User.find_by(email: user.email)
      self.user = new_user
    elsif user
      user.save!
      self.user = user
    end
  end
end
