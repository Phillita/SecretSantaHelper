# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryGirl.build_stubbed(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_length_of(:first_name).is_at_most(50) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(50) }
    it { is_expected.to allow_value('', nil).for(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_length_of(:email).is_at_most(255) }
    it { is_expected.not_to validate_presence_of(:password) }
    it { is_expected.not_to validate_length_of(:password).is_at_least(6) }

    context 'when setting a password' do
      subject { FactoryGirl.build(:user, password_confirmation: 'password') }

      it { is_expected.to validate_presence_of(:password) }
      it { is_expected.to validate_length_of(:password).is_at_least(8) }
      it { is_expected.to allow_value('Password1').for(:password) }
      it { is_expected.not_to allow_value(nil, 'password', 'password1', 'Password').for(:password) }
    end

    context 'guest' do
      subject { FactoryGirl.build(:user_guest) }

      it { is_expected.not_to validate_presence_of(:password) }
      it { is_expected.not_to validate_length_of(:password).is_at_least(8) }
    end
  end

  describe 'name' do
    it 'shoud return the name of the user' do
      expect(user.name).to eq("#{user.first_name} #{user.last_name}")
    end
  end

  describe 'guest?' do
    it 'should return true if the guast attribute has a value' do
      expect(user.guest?).to be_falsey
      user.guest = Time.now
      expect(user.guest?).to be_truthy
    end
  end
end
