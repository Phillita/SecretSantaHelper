# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecretSantaParticipantMatch, type: :model do
  describe 'Relationships' do
    it { should belong_to(:secret_santa_participant) }
    it { should belong_to(:match) }
  end

  describe 'delegates' do
    it { should delegate_method(:name).to(:match) }
    it { should delegate_method(:name).to(:secret_santa_participant).with_prefix(:giver) }
  end

  describe 'success?' do
    it "should return true if matched participant didn't add an exception matching the secret_santa_participant" do
      expect(FactoryGirl.build_stubbed(:secret_santa_participant_match).success?).to be_truthy
    end

    it 'should return false if the match and the participant are the same' do
      match = FactoryGirl.build_stubbed(:secret_santa_participant_match)
      match.match = match.secret_santa_participant
      expect(match.success?).to be_falsey
    end

    it "should return false if matched participant added an exception matching the secret_santa_participant" do
      match = FactoryGirl.build(:secret_santa_participant_match)
      match.secret_santa_participant.secret_santa_participant_exceptions << FactoryGirl.build(:secret_santa_participant_exception, exception: match.match)
      expect(match.success?).to be_falsey
    end
  end
end
