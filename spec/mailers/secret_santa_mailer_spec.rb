# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecretSantaMailer, type: :mailer do
  let(:secret_santa_participant) { FactoryGirl.build_stubbed(:secret_santa_participant) }
  let(:secret_santa) { FactoryGirl.build_stubbed(:secret_santa) }
  let(:match_name) { 'Match Name' }

  describe 'participant' do
    before(:each) do
      expect(SecretSantaParticipant).to receive(:find).with(secret_santa_participant.id).and_return(secret_santa_participant)
      secret_santa.send(:default_email_and_file)
      allow(secret_santa_participant).to receive(:participantable).and_return(secret_santa)
    end

    subject { SecretSantaMailer.participant(secret_santa_participant.id, match_name) }

    it 'should have the sender set to the secret santa app' do
      expect(subject.from).to eq(['santas.app.helper@gmail.com'])
    end

    it 'should match the content set by the secret santa object' do
      template = Liquid::Template.parse(secret_santa_participant.participantable.email_content)
      expect(subject.body.to_s).to match(
        template.render(
          'Giver' => secret_santa_participant.user.name,
          'Receiver' => match_name,
          'SecretSanta' => secret_santa_participant.participantable.name
        )
      )
    end

    it 'should have the participans email in the to' do
      expect(subject.to).to eq([secret_santa_participant.email])
    end

    it 'should match the subject set by the secret santa object' do
      template = Liquid::Template.parse(secret_santa_participant.participantable.email_subject)
      expect(subject.subject).to match(
        template.render(
          'Giver' => secret_santa_participant.user.name,
          'Receiver' => match_name,
          'SecretSanta' => secret_santa_participant.participantable.name
        )
      )
    end

    context 'with filepath' do
      let(:filepath) { "#{Rails.root}/spec/fixtures/secret_santa_file.txt" }
      subject { SecretSantaMailer.participant(secret_santa_participant.id, match_name, filepath) }

      it 'should connect a file to the email' do
        expect(subject.attachments.size).to eq(1)
        attachment = subject.attachments.first
        expect(attachment).to be_a_kind_of(Mail::Part)
        expect(attachment.content_type).to start_with('text/plain;')
        expect(attachment.filename).to eq('secret_santa_file.txt')
      end
    end
  end
end
