# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecretSanta, type: :model do
  let(:secret_santa_email) { FactoryGirl.build(:secret_santa) }

  describe 'relationships' do
    it { should belong_to(:user) }
    it { should have_many(:secret_santa_participants) }
    it { should have_many(:secret_santa_participant_matches).through(:secret_santa_participants) }
  end

  describe 'validations' do
    it { should validate_presence_of(:slug) }
  end

  describe 'test?' do
    it 'should return true if the test flag is on' do
      expect(FactoryGirl.build(:secret_santa_test, :send_an_email).test?).to be_truthy
    end

    it 'should return true if the system is unable to send to the participants' do
      expect(FactoryGirl.build(:secret_santa).test?).to be_truthy
    end

    it 'should return false if the test conditions are not met' do
      expect(FactoryGirl.build(:secret_santa_with_email).test?).to be_falsey
    end
  end

  describe 'unable_to_send?' do
    it 'returns true if both file and email are off' do
      expect(FactoryGirl.build(:secret_santa).unable_to_send?).to be_truthy
    end

    it 'returns false if email is on' do
      expect(FactoryGirl.build(:secret_santa_with_email).unable_to_send?).to be_falsey
    end

    it 'returns false if file is on' do
      expect(FactoryGirl.build(:secret_santa_with_file).unable_to_send?).to be_falsey
    end
  end

  describe 'ready?' do
    it 'should return true if there are participants and they can all be matched' do
      ss = FactoryGirl.create(:secret_santa)
      FactoryGirl.create_list(:secret_santa_participant, 2, participantable: ss)
      expect(ss.ready?).to be_truthy
    end

    it 'should return false if there are no participants' do
      expect(FactoryGirl.build(:secret_santa).ready?).to be_falsey
    end

    it "should return false if there are participants but they can't all be matched" do
      ss = FactoryGirl.create(:secret_santa)
      participants = FactoryGirl.create_list(:secret_santa_participant, 2, participantable: ss)
      FactoryGirl.create(:secret_santa_participant_exception, exception: participants.first, secret_santa_participant: participants.last)
      expect(ss.ready?).to be_falsey
    end
  end

  describe 'complete?' do
    it 'should return true if there is a last_run_on date' do
      expect(FactoryGirl.build(:secret_santa_complete).complete?).to be_truthy
    end

    it 'should return fasle if the secret santa has not run' do
      expect(FactoryGirl.build(:secret_santa).complete?).to be_falsey
    end
  end

  describe 'secure?' do
    it 'should return true if there is a passphrase' do
      expect(FactoryGirl.build(:secret_santa_secure).secure?).to be_truthy
    end

    it 'should return false if there is no passphrase' do
      expect(FactoryGirl.build(:secret_santa).secure?).to be_falsey
    end
  end

  describe 'to_h?' do
    it 'returns a hash of secret santa and all its participants' do
      ss = FactoryGirl.create(:secret_santa)
      participants = FactoryGirl.create_list(:secret_santa_participant, 2, participantable: ss)
      ss_hsh = ss.to_h
      expect(ss_hsh.keys).to eq(participants.collect(&:id))
    end
  end

  describe 'make_magic?' do
    it 'should call the SecretSantaService' do
      ss = FactoryGirl.build(:secret_santa)
      expect(SecretSantaService).to receive(:new).with(ss).and_call_original
      expect_any_instance_of(SecretSantaService).to receive(:make_magic!).and_return(true)
      ss.make_magic!
    end
  end

  describe 'clone?' do
    it 'should call the clone service' do
      ss = FactoryGirl.create(:secret_santa)
      expect(SecretSantaCloner).to receive(:new).with(ss).and_call_original
      expect_any_instance_of(SecretSantaCloner).to receive(:clone).and_return(true)
      expect_any_instance_of(SecretSantaCloner).to receive(:cloned_secret_santa).and_return(true)
      ss.clone
    end
  end
end
