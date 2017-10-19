# frozen_string_literal: false

class SecretSanta < ApplicationRecord
  include ArelHelpers::ArelTable
  extend FriendlyId
  self.table_name = 'secret_santas'

  belongs_to :user, autosave: true, inverse_of: :secret_santas
  alias_attribute :owner, :user
  has_many :secret_santa_participants, as: :participantable, dependent: :destroy
  has_many :secret_santa_participant_matches, dependent: :destroy

  validates :slug, presence: true

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :secret_santa_participants, reject_if: :all_blank, allow_destroy: true

  before_create :default_email_and_file

  friendly_id :name, use: %i[slugged finders]

  scope :by_email, (->(email) { joins(:user).where(User[:email].matches("%#{email}%")) unless email.blank? })
  scope :by_name, (->(name) { where(SecretSanta[:name].matches("%#{name}%")) unless name.blank? })

  def autosave_associated_records_for_user
    if !user&.persisted? && User.exists?(email: user.email)
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

  # either the user said this is a test or has selected to not have a file or email sent
  def test?
    test_run.present? || unable_to_send?
  end

  def unable_to_send?
    !send_email? && !send_file?
  end

  def ready?
    secret_santa_participants.any? && participants_can_all_be_matched?
  end

  def complete?
    last_run_on.present?
  end

  def secure?
    passphrase.present?
  end

  def to_h
    {}.tap do |hsh|
      secret_santa_participants.each do |participant|
        hsh[participant.id] = participant.to_h
      end
    end
  end

  def make_magic!
    SecretSantaService.new(self).make_magic!
  end

  def clone
    service = SecretSantaCloner.new(self)
    return service.cloned_secret_santa if service.clone
  end

  private

  def participants_can_all_be_matched?
    secret_santa_participants.collect do |participant|
      secret_santa_participants
        .joins(
          ArelHelpers.join_association(
            SecretSantaParticipant,
            :secret_santa_participant_exceptions,
            Arel::Nodes::OuterJoin
          )
        )
        .joins(
          ArelHelpers.join_association(SecretSantaParticipant, :secret_santa_participant_match, Arel::Nodes::OuterJoin)
        )
        .where(
          SecretSantaParticipant[:id].not_eq(participant.id)
          .and(
            SecretSantaParticipantMatch[:id].eq(nil)
            .or(SecretSantaParticipantMatch[:test].eq(true))
          )
          .and(
            SecretSantaParticipantException[:exception_id].not_eq(participant.id)
            .or(SecretSantaParticipantException[:id].eq(nil))
          )
        ).any?
    end.reject { |truthy_falsey| truthy_falsey }.empty?
  end

  def default_email_and_file
    self.email_subject = '{{Giver}}: Find your SecretSanta Enclosed!'
    self.email_content = 'Hey {{Giver}}! Just in case you were wondering... Your Secret Santa for {{SecretSanta}} is: {{Receiver}}'
    self.filename = '{{Giver}}-secret-santa'
    self.file_content = 'Hey {{Giver}}! Just in case you were wondering... Your Secret Santa for {{SecretSanta}} is: {{Receiver}}'
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
