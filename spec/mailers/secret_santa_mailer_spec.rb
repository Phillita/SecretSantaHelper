require 'rails_helper'

RSpec.describe SecretSantaMailer, type: :mailer do
  let(:secret_santa_participant) { FactoryGirl.create(:secret_santa_participant) }

  describe 'participant' do
    subject { SecretSantaMailer.participant(secret_santa_participant.id) }

    it 'should have the sender set to the secret santa app' do
      expect(subject.from).to eq(['santas.app.helper@gmail.com'])
    end

    it 'should match the content set by the secret santa object' do
      template = Liquid::Template.parse(secret_santa_participant.participantable.email_content)
      expect(subject.body.to_s).to match(
        template.render(
          'Giver' => secret_santa_participant.user.name,
          'Receiver' => 'match name',
          'SecretSanta' => secret_santa_participant.participantable.name)
        )
    end

    it 'should have the participans email in the to' do
      expect(subject.to).to eq([secret_santa_participant.email])
    end

    it 'should match the subject set by the secret santa object' do
      expect(subject.subject).to eq(secret_santa_participant.participantable.email_subject)
    end
  end
end
