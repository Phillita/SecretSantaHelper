# frozen_string_literal: true

class SecretSantaParticipantException < ApplicationRecord
  include ArelHelpers::ArelTable

  belongs_to :exception, class_name: 'SecretSantaParticipant'
  belongs_to :secret_santa_participant

  delegate :name, to: :exception
end
