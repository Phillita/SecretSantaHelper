# frozen_string_literal: true

class SecretSantaMailer < ApplicationMailer
  default from: 'Secret Santa App <santas.app.helper@gmail.com>'

  def participant(participant_id, receiver_name, filepath = nil)
    participant = SecretSantaParticipant.find(participant_id)
    secret_santa = participant.participantable
    options = liquid_options(secret_santa, participant, receiver_name)
    email_subject = parse_liquid(secret_santa.email_subject, options)
    email_content = parse_liquid(secret_santa.email_content, options)
    attach_file(filepath) if filepath
    mail(to: participant.user.email, subject: email_subject, body: email_content)
  end

  private

  def attach_file(filepath)
    attachments[Pathname.new(filepath).basename.to_s] = File.read(filepath)
  end

  def parse_liquid(text, options)
    template = Liquid::Template.parse(text)
    template.render(options)
  end

  def liquid_options(secret_santa, participant, receiver_name)
    {
      'Giver' => participant.user.name,
      'Receiver' => receiver_name,
      'SecretSanta' => secret_santa.name
    }
  end
end
