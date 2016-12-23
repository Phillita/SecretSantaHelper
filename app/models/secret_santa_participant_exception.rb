class SecretSantaParticipantException < ActiveRecord::Base
  belongs_to :user
  belongs_to :secret_santa_participant
end
