# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecretSanta, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:secret_santa_participants) }
    it { is_expected.to have_many(:secret_santa_participant_matches).through(:secret_santa_participants) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:slug) }
  end

  describe 'delegates' do
    it { is_expected.to respond_to(:owner) }
  end

  describe 'scopes' do
    context 'by_email' do
      it 'should find secret santas that match an email' do
        user = FactoryGirl.create(:user, email: 'joker@arkham.com')
        FactoryGirl.create_list(:secret_santa, 2, user: user)
        FactoryGirl.create_list(:secret_santa, 3)
        expect(SecretSanta.by_email('joker').size).to eq(2)
      end
    end

    context 'by_name' do
      it 'should find secret santas that match an email' do
        FactoryGirl.create(:secret_santa, name: 'Serious Secret Santa')
        FactoryGirl.create_list(:secret_santa, 2)
        expect(SecretSanta.by_name('serious').size).to eq(1)
      end
    end
  end

  context 'create' do
    describe 'autosave_associated_records_for_user' do
      it 'should use an existing user rather then creating a new one' do
        u = FactoryGirl.create(:user)
        ss = SecretSanta.create(slug: 'HULKSMASH', user_attributes: { first_name: 'The', last_name: 'Hulk', email: u.email, guest: Time.now })
        expect(ss.user_id).to eq(u.id)
      end

      it "should create a new user if one doesn't exist" do
        ss = SecretSanta.create(user_attributes: { first_name: 'The', last_name: 'Hulk', email: 'hulky@smash.ca', guest: Time.now })

        expect(ss.user.name).to eq('The Hulk')
        expect(ss.user.email).to eq('hulky@smash.ca')
      end
    end
  end

  describe 'test?' do
    it 'should return true if the test flag is on' do
      expect(FactoryGirl.build_stubbed(:secret_santa_test, :send_an_email).test?).to be_truthy
    end

    it 'should return true if the system is unable to send to the participants' do
      expect(FactoryGirl.build_stubbed(:secret_santa).test?).to be_truthy
    end

    it 'should return false if the test conditions are not met' do
      expect(FactoryGirl.build_stubbed(:secret_santa_with_email).test?).to be_falsey
    end
  end

  describe 'unable_to_send?' do
    it 'returns true if both file and email are off' do
      expect(FactoryGirl.build_stubbed(:secret_santa).unable_to_send?).to be_truthy
    end

    it 'returns false if email is on' do
      expect(FactoryGirl.build_stubbed(:secret_santa_with_email).unable_to_send?).to be_falsey
    end

    it 'returns false if file is on' do
      expect(FactoryGirl.build_stubbed(:secret_santa_with_file).unable_to_send?).to be_falsey
    end
  end

  describe 'ready?' do
    it 'should return true if there are participants and they can all be matched' do
      ss = FactoryGirl.create(:secret_santa)
      FactoryGirl.create_list(:secret_santa_participant, 2, participantable: ss)
      expect(ss.ready?).to be_truthy
    end

    it 'should return false if there are no participants' do
      expect(FactoryGirl.build_stubbed(:secret_santa).ready?).to be_falsey
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
      expect(FactoryGirl.build_stubbed(:secret_santa_complete).complete?).to be_truthy
    end

    it 'should return fasle if the secret santa has not run' do
      expect(FactoryGirl.build_stubbed(:secret_santa).complete?).to be_falsey
    end
  end

  describe 'secure?' do
    it 'should return true if there is a passphrase' do
      expect(FactoryGirl.build_stubbed(:secret_santa_secure).secure?).to be_truthy
    end

    it 'should return false if there is no passphrase' do
      expect(FactoryGirl.build_stubbed(:secret_santa).secure?).to be_falsey
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
      ss = FactoryGirl.build_stubbed(:secret_santa)
      expect(SecretSantaService).to receive(:new).with(ss).and_call_original
      expect_any_instance_of(SecretSantaService).to receive(:make_magic!).and_return(true)
      ss.make_magic!
    end
  end

  describe 'clone?' do
    it 'should call the clone service' do
      ss = FactoryGirl.build_stubbed(:secret_santa)
      expect(SecretSantaCloner).to receive(:new).with(ss).and_call_original
      expect_any_instance_of(SecretSantaCloner).to receive(:clone).and_return(true)
      expect_any_instance_of(SecretSantaCloner).to receive(:cloned_secret_santa).and_return(true)
      ss.clone
    end
  end
end
