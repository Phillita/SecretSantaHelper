class SecretSantaParticipantException < ActiveRecord::Base
  include ArelHelpers::ArelTable

  belongs_to :exception, class_name: 'SecretSantaParticipant'
  belongs_to :secret_santa_participant

  delegate :name, to: :exception
end
