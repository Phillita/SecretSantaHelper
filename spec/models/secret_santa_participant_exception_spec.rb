require 'rails_helper'

RSpec.describe SecretSantaParticipantException, type: :model do
  describe 'Relationships' do
    it { should belong_to(:secret_santa_participant) }
    it { should belong_to(:exception) }
  end
end
