# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecretSantaParticipant, type: :model do
  describe 'relationships' do
    it { is_expected.to have_many(:secret_santa_participant_exceptions) }
    it { is_expected.to have_many(:secret_santa_participant_exceptions_of) }
    it { is_expected.to have_one(:secret_santa_participant_match) }
  end

  describe 'to_h' do
    it 'should return a hash of attributes and exception ids' do
      participant = FactoryGirl.build_stubbed(:secret_santa_participant)
      expect(participant).to receive_message_chain(:secret_santa_participant_exceptions, :pluck).and_return([1, 2, 3])

      expect(participant.to_h). to eq(
        {
          name: participant.name,
          email: participant.email,
          exceptions: [1, 2, 3]
        }
      )
    end
  end
end
