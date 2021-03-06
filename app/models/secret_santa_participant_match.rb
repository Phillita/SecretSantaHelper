# frozen_string_literal: true

class SecretSantaParticipantMatch < ApplicationRecord
  include ArelHelpers::ArelTable
  attr_accessor :file

  belongs_to :secret_santa
  belongs_to :match, class_name: 'SecretSantaParticipant'
  belongs_to :secret_santa_participant

  validates :secret_santa_id, presence: true
  validates :secret_santa_participant_id, :match_id, uniqueness: { scope: :secret_santa_id }

  delegate :name, to: :match
  delegate :name, to: :secret_santa_participant, prefix: :giver

  def success?
    no_exceptions? && not_the_same?
  end

  private

  def no_exceptions?
    !secret_santa_participant.secret_santa_participant_exceptions.exists?(exception_id: match_id)
  end

  def not_the_same?
    match_id != secret_santa_participant_id
  end
end
