# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecretSantaService do
  let(:secret_santa) { FactoryGirl.create(:secret_santa) }

  describe 'attributes' do
    subject { SecretSantaService.new(secret_santa) }

    it { should respond_to(:secret_santa) }
    it { should respond_to(:matches) }
  end

  describe 'make_magic!' do
    let!(:secret_santa_participants) do
      FactoryGirl.create_list(:secret_santa_participant, 3, participantable: secret_santa)
    end
    let!(:secret_santa_participant_exception) do
      FactoryGirl.create(:secret_santa_participant_exception,
                         secret_santa_participant: secret_santa_participants.first,
                         exception: secret_santa_participants.last)
    end

    subject { secret_santa.make_magic! }

    context 'test on' do
      let(:secret_santa) { FactoryGirl.create(:secret_santa_test) }

      it 'should match all participants' do
        expect(subject).to be_truthy
        expect(secret_santa.reload.last_run_on).to be_nil

        participant1 = secret_santa.secret_santa_participants.first
        participant2 = secret_santa.secret_santa_participants.second
        participant3 = secret_santa.secret_santa_participants.third

        expect(participant1.secret_santa_participant_match).not_to be_nil
        expect(participant1.secret_santa_participant_match).not_to eq(participant3)
        expect(participant1.secret_santa_participant_match.test?).to be_truthy
        expect(participant2.secret_santa_participant_match).not_to be_nil
        expect(participant2.secret_santa_participant_match.test?).to be_truthy
        expect(participant3.secret_santa_participant_match).not_to be_nil
        expect(participant3.secret_santa_participant_match.test?).to be_truthy
      end
    end

    context "doesn't have a delivery method set" do
      it 'should match all participants' do
        expect(subject).to be_truthy
        expect(secret_santa.reload.last_run_on).to be_nil

        participant1 = secret_santa.secret_santa_participants.first
        participant2 = secret_santa.secret_santa_participants.second
        participant3 = secret_santa.secret_santa_participants.third

        expect(participant1.secret_santa_participant_match).not_to be_nil
        expect(participant1.secret_santa_participant_match).not_to eq(participant3)
        expect(participant1.secret_santa_participant_match.test?).to be_truthy
        expect(participant2.secret_santa_participant_match).not_to be_nil
        expect(participant2.secret_santa_participant_match.test?).to be_truthy
        expect(participant3.secret_santa_participant_match).not_to be_nil
        expect(participant3.secret_santa_participant_match.test?).to be_truthy
      end
    end

    context 'email delivery method on' do
      let(:secret_santa) { FactoryGirl.create(:secret_santa_with_email) }

      it 'should match all participants' do
        expect(subject).to be_truthy
        expect(secret_santa.reload.last_run_on).not_to be_nil

        participant1 = secret_santa.secret_santa_participants.first
        participant2 = secret_santa.secret_santa_participants.second
        participant3 = secret_santa.secret_santa_participants.third

        expect(participant1.secret_santa_participant_match).not_to be_nil
        expect(participant1.secret_santa_participant_match).not_to eq(participant3)
        expect(participant1.secret_santa_participant_match.test?).to be_falsey
        expect(participant2.secret_santa_participant_match).not_to be_nil
        expect(participant2.secret_santa_participant_match.test?).to be_falsey
        expect(participant3.secret_santa_participant_match).not_to be_nil
        expect(participant3.secret_santa_participant_match.test?).to be_falsey
      end
    end

    context 'file delivery method on' do
      let(:secret_santa) { FactoryGirl.create(:secret_santa_with_file) }

      it 'should match all participants' do
        expect(subject).to be_truthy
        expect(secret_santa.reload.last_run_on).not_to be_nil

        participant1 = secret_santa.secret_santa_participants.first
        participant2 = secret_santa.secret_santa_participants.second
        participant3 = secret_santa.secret_santa_participants.third

        expect(participant1.secret_santa_participant_match).not_to be_nil
        expect(participant1.secret_santa_participant_match).not_to eq(participant3)
        expect(participant1.secret_santa_participant_match.test?).to be_falsey
        expect(participant2.secret_santa_participant_match).not_to be_nil
        expect(participant2.secret_santa_participant_match.test?).to be_falsey
        expect(participant3.secret_santa_participant_match).not_to be_nil
        expect(participant3.secret_santa_participant_match.test?).to be_falsey
      end
    end

    context 'file/email delivery method on' do
      let(:secret_santa) { FactoryGirl.create(:secret_santa_with_email_and_file) }

      it 'should match all participants' do
        expect(subject).to be_truthy
        expect(secret_santa.reload.last_run_on).not_to be_nil

        participant1 = secret_santa.secret_santa_participants.first
        participant2 = secret_santa.secret_santa_participants.second
        participant3 = secret_santa.secret_santa_participants.third

        expect(participant1.secret_santa_participant_match).not_to be_nil
        expect(participant1.secret_santa_participant_match).not_to eq(participant3)
        expect(participant1.secret_santa_participant_match.test?).to be_falsey
        expect(participant2.secret_santa_participant_match).not_to be_nil
        expect(participant2.secret_santa_participant_match.test?).to be_falsey
        expect(participant3.secret_santa_participant_match).not_to be_nil
        expect(participant3.secret_santa_participant_match.test?).to be_falsey
      end
    end
  end
end
