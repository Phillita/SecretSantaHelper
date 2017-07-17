# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecretSantaParticipantException, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to(:secret_santa_participant) }
    it { is_expected.to belong_to(:exception) }
  end
end
