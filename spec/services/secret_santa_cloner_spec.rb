# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecretSantaCloner do
  let(:secret_santa) { FactoryGirl.create(:secret_santa_started) }

  describe 'attributes' do
    subject { SecretSantaCloner.new(secret_santa) }

    it { is_expected.to respond_to(:cloned_secret_santa) }
  end

  describe 'clone' do
    let!(:secret_santa_participants) { FactoryGirl.create_list(:secret_santa_participant, 3, participantable: secret_santa) }
    let!(:secret_santa_participant_exception) do
      FactoryGirl.create(:secret_santa_participant_exception,
                         secret_santa_participant: secret_santa_participants.first,
                         exception: secret_santa_participants.last)
    end

    subject { secret_santa.clone }

    it 'should clone the secret santa exactly' do
      expect(subject.secret_santa_participants.size).to eq(3)
      expect(subject.name).to eq("Cloned: #{secret_santa.name}")
      expect(subject.last_run_on).to be_nil

      participant1 = subject.secret_santa_participants.first
      participant2 = subject.secret_santa_participants.second
      participant3 = subject.secret_santa_participants.third

      expect(participant1.secret_santa_participant_exceptions.size).to eq(1)
      expect(participant1.secret_santa_participant_exceptions_of.size).to eq(0)
      expect(participant2.secret_santa_participant_exceptions.size).to eq(0)
      expect(participant2.secret_santa_participant_exceptions_of.size).to eq(0)
      expect(participant3.secret_santa_participant_exceptions.size).to eq(0)
      expect(participant3.secret_santa_participant_exceptions_of.size).to eq(1)
    end
  end
end
