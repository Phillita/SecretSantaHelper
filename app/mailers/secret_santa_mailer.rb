class SecretSantaMailer < ApplicationMailer
  default from: 'Secret Santa App <santas.app.helper@gmail.com>'

  def participant(participant_id)
    participant = SecretSantaParticipant.find(participant_id)
    secret_santa = participant.participantable
    # mail.add_file(v[:file])
    # mail.deliver
    mail(to: participant.user.email, subject: secret_santa.email_subject, body: liquid_body(secret_santa, participant))
  end

  private

  def liquid_body(secret_santa, participant)
    template = Liquid::Template.parse(secret_santa.email_content)
    template.render(
      'Giver' => participant.user.name,
      'Receiver' => 'match name',
      'SecretSanta' => secret_santa.name)
  end
end
