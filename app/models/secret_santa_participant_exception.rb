class SecretSantaParticipantException < ActiveRecord::Base
  include ArelHelpers::ArelTable

  belongs_to :user
  belongs_to :secret_santa_participant
end
