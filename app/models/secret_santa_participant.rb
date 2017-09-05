# frozen_string_literal: true

class SecretSantaParticipant < Participant
  has_many :secret_santa_participant_exceptions, dependent: :destroy
  has_many :secret_santa_participant_exceptions_of,
           class_name: 'SecretSantaParticipantException',
           foreign_key: :exception_id
  has_one :secret_santa_participant_match, dependent: :destroy
  belongs_to :user, autosave: true, inverse_of: :secret_santa_participants

  accepts_nested_attributes_for :secret_santa_participant_exceptions, reject_if: :all_blank, allow_destroy: true

  def to_h
    {}.tap do |hsh|
      hsh[:name] = name
      hsh[:email] = email
      hsh[:exceptions] = secret_santa_participant_exceptions.pluck(:exception_id)
    end
  end
end
