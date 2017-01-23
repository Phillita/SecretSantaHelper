class SecretSantaMailer < ApplicationMailer
  default from: 'Secret Santa App <santas.app.helper@gmail.com>'

  def participant(participant_id, receiver_name, filepath = nil)
    participant = SecretSantaParticipant.find(participant_id)
    secret_santa = participant.participantable
    email_content = liquid_body(secret_santa, participant, receiver_name)
    attach_file(filepath) if filepath
    mail(to: participant.user.email, subject: secret_santa.email_subject, body: email_content)
  end

  private

  def attach_file(filepath)
    attachments[Pathname.new(filepath).basename.to_s] = File.read(filepath)
  end

  def liquid_body(secret_santa, participant, receiver_name)
    template = Liquid::Template.parse(secret_santa.email_content)
    template.render(
      'Giver' => participant.user.name,
      'Receiver' => receiver_name,
      'SecretSanta' => secret_santa.name)
  end
end
