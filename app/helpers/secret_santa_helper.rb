module SecretSantaHelper
  def secret_santa_wizard_step(step)
    "step_#{step}"
  end

  def exceptions_for_secret_santa_participant(participant_id, secret_santa)
    SecretSantaParticipant.where(participantable: secret_santa).where.not(id: participant_id).collect(&:user)
  end
end
