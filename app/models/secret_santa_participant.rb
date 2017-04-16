# frozen_string_literal: true

class SecretSantaParticipant < Participant
  has_many :secret_santa_participant_exceptions, dependent: :destroy
  has_one :secret_santa_participant_match, dependent: :destroy

  accepts_nested_attributes_for :secret_santa_participant_exceptions, reject_if: :all_blank, allow_destroy: true

  def to_h
    {}.tap do |hsh|
      hsh[:name] = name
      hsh[:email] = email
      hsh[:exceptions] = [].tap do |arr|
        secret_santa_participant_exceptions.each do |exception|
          arr << exception.exception_id
        end
      end
    end
  end
end
