require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { FactoryGirl.create(:user) }

  describe 'validations' do
    it 'should be valid' do
      expect(user.valid?).to be_truthy
    end

    context 'name should be present' do
      it 'should return false if the first_name is blank' do
        user.first_name = '     '
        expect(user.valid?).to be_falsey
      end

      it 'should return true if the last_name is blank' do
        user.last_name = '     '
        expect(user.valid?).to be_truthy
      end
    end

    context 'email should be present' do
      it 'should return false if the email is blank' do
        user.email = '     '
        expect(user.valid?).to be_falsey
      end
    end

    context 'name is not too long' do
      it 'should return false if the first_name is too long' do
        user.first_name = 'a' * 51
        expect(user.valid?).to be_falsey
      end

      it 'should return false if the last_name is too long' do
        user.last_name = 'a' * 51
        expect(user.valid?).to be_falsey
      end
    end

    context 'email is not too long' do
      it 'should return false if the email is too long' do
        user.email = 'a' * 244 + '@example.com'
        expect(user.valid?).to be_falsey
      end
    end

    context 'valid email format' do
      it 'should return tru if the email address is valid' do
        valid_addresses = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org
                             first.last@foo.jp alice+bob@baz.cn)
        valid_addresses.each do |valid_address|
          user.email = valid_address
          expect(user.valid?).to be_truthy
        end
      end

      it 'should reject all invalid email addresses' do
        invalid_addresses = %w(user@example,com user_at_foo.org user.name@example.
                               foo@bar_baz.com foo@bar+baz.com)
        invalid_addresses.each do |invalid_address|
          user.email = invalid_address
          expect(user.valid?).to be_falsey
        end
      end
    end

    context 'unique email' do
      it 'should reject duplicate users' do
        duplicate_user = user.dup
        duplicate_user.email = user.email.upcase
        user.save
        expect(duplicate_user.valid?).to be_falsey
      end
    end

    context 'has a secure password' do
      it 'should have a password present' do
        user.password = user.password_confirmation = ' ' * 6
        expect(user.valid?).to be_falsey
      end

      it 'should have a min length for the password' do
        user.password = user.password_confirmation = 'a' * 5
        expect(user.valid?).to be_falsey
      end
    end
  end

  describe 'name' do
    it 'shoud return the name of the user' do
      expect(user.name).to eq("#{user.first_name} #{user.last_name}")
    end
  end
end
