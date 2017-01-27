require 'rails_helper'

RSpec.describe SecretSanta, type: :model do
  describe 'relationships' do
    it { should belong_to(:user) }
    it { should have_many(:secret_santa_participants) }
  end
end
