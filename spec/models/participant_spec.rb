# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Participant, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:participantable) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:participantable) }
    it { is_expected.to validate_presence_of(:user) }
  end

  describe 'delegates' do
    it { is_expected.to delegate_method(:name).to(:user) }
    it { is_expected.to delegate_method(:email).to(:user) }
  end

  context 'create' do
    describe 'autosave_associated_records_for_user' do
      it 'should use an existing user rather then creating a new one' do
        u = FactoryGirl.create(:user, email: 'hulk@smash.ca')
        ss = FactoryGirl.create(:secret_santa)
        p = Participant.create(participantable: ss, user_attributes: { first_name: 'The', last_name: 'Hulk', email: 'hulk@smash.ca', guest: Time.now })

        expect(p.user_id).to eq(u.id)
      end

      it "should create a new user if one doesn't exist" do
        ss = FactoryGirl.create(:secret_santa)
        p = Participant.create(participantable: ss, user_attributes: { first_name: 'The', last_name: 'Hulk', email: 'hulk@smash.ca', guest: Time.now })

        expect(p.name).to eq('The Hulk')
        expect(p.email).to eq('hulk@smash.ca')
      end
    end
  end
end
