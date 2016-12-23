class SecretSantaParticipant < Participant
  has_many :secret_santa_participant_exceptions

  accepts_nested_attributes_for :secret_santa_participant_exceptions, reject_if: :all_blank, allow_destroy: true
end
