# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecretSantaParticipantMatch, type: :model do
  describe 'Relationships' do
    it { should belong_to(:secret_santa_participant) }
    it { should belong_to(:match) }
  end

  describe 'delegates' do
    pending 'name sends out the metch name'
    pending 'giver_name sends out the participant name'
  end
end
