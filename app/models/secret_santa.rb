class SecretSanta < ActiveRecord::Base
  include ArelHelpers::ArelTable
  extend FriendlyId
  self.table_name = 'secret_santas'

  belongs_to :user, autosave: true
  alias_attribute :owner, :user
  has_many :secret_santa_participants, as: :participantable, dependent: :destroy
  has_many :secret_santa_participant_matches, through: :secret_santa_participants, dependent: :destroy

  validates :slug, presence: true

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :secret_santa_participants, reject_if: :all_blank, allow_destroy: true

  before_create :default_email_and_file

  friendly_id :name, use: [:slugged, :finders]

  def autosave_associated_records_for_user
    if user && new_user = User.find_by(email: user.email)
      self.user = new_user
    elsif user
      user.save!
      self.user = user
    end
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
          ArelHelpers.join_association(SecretSantaParticipant, :secret_santa_participant_exceptions, Arel::Nodes::OuterJoin))
        .where(
          SecretSantaParticipant[:id].not_eq(participant.id)
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
