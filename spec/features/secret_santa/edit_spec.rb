# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Editing a Secret Santa', js: true do
  let(:secret_santa) { FactoryGirl.create(:secret_santa, user: black_widow, name: 'Test') }
  let!(:secret_santa_participant) { FactoryGirl.create(:secret_santa_participant, user: black_widow, participantable: secret_santa) }
  let!(:secret_santa_participant2) { FactoryGirl.create(:secret_santa_participant, user: thor, participantable: secret_santa) }

  context 'as a guest user' do
    let!(:black_widow) { FactoryGirl.create(:user_guest, first_name: 'B', last_name: 'W', email: 'bw@avengers.com') }
    let!(:thor) { FactoryGirl.create(:user_guest, first_name: 'Thor', last_name: '', email: 'thor@avengers.com') }

    before(:each) do
      visit secret_santum_path(secret_santa)
      click_link 'edit-secret-santa'
    end

    it 'lets you change the name of the secret santa' do
      fill_in :secret_santa_name, with: 'Avengers First Secret Santa'
      expect { click_button 'Next' }.to change { secret_santa.reload.name }.from('Test').to('Avengers First Secret Santa')
    end

    it 'lets you change your account name and email' do
      fill_in :secret_santa_user_attributes_first_name, with: 'Black'
      fill_in :secret_santa_user_attributes_last_name, with: 'Widow'
      fill_in :secret_santa_user_attributes_email, with: 'bwidow@avengers.com'

      click_button 'Next'

      black_widow.reload
      expect(black_widow.first_name).to eq('Black')
      expect(black_widow.last_name).to eq('Widow')
      expect(black_widow.email).to eq('bwidow@avengers.com')
    end

    it 'lets you change the passphrase' do
      fill_in :secret_santa_passphrase, with: 'Avengers Only'
      expect { click_button 'Next' }.to change { secret_santa.reload.passphrase }.from(nil).to('Avengers Only')
    end

    it 'lets you add a participant' do
      click_link "Who's in?"
      click_link 'top-link-to-add-participant'

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_first_name')]").last.set('Incredible')
        all(:xpath, "//input[contains(@id,'_user_attributes_last_name')]").last.set('Hulk')
        all(:xpath, "//input[contains(@id,'_user_attributes_email')]").last.set('ihulk@avengers.com')
      end

      expect { click_button 'Next' }.to change { secret_santa.secret_santa_participants.count }.from(2).to(3)
    end

    it 'lets you add an exception' do
      click_link 'Any Exceptions?'
      select 'Thor', from: 'secret_santa_secret_santa_participants_attributes_0_secret_santa_participant_exceptions_attributes_0_exception_id'
      click_button 'Finish'
      expect(secret_santa_participant.secret_santa_participant_exceptions.count).to eq(1)
    end
  end

  context 'as a logged in user' do
    let!(:black_widow) { FactoryGirl.create(:user, first_name: 'B', last_name: 'W', email: 'bw@avengers.com') }
    let!(:thor) { FactoryGirl.create(:user, first_name: 'Thor', last_name: '', email: 'thor@avengers.com') }
    
    before(:each) do
      visit secret_santum_path(secret_santa)
      click_link 'edit-secret-santa'
    end
    
    it 'lets you change the name of the secret santa' do
      fill_in :secret_santa_name, with: 'Avengers First Secret Santa'
      expect { click_button 'Next' }.to change { secret_santa.reload.name }.from('Test').to('Avengers First Secret Santa')
    end

    it 'lets you change your account name and email (confirmation required)' do
      fill_in :secret_santa_user_attributes_first_name, with: 'Black'
      fill_in :secret_santa_user_attributes_last_name, with: 'Widow'
      fill_in :secret_santa_user_attributes_email, with: 'bwidow@avengers.com'

      click_button 'Next'

      black_widow.reload
      expect(black_widow.first_name).to eq('Black')
      expect(black_widow.last_name).to eq('Widow')
      expect(black_widow.email).to eq('bw@avengers.com')
      expect(black_widow.unconfirmed_email).to eq('bwidow@avengers.com')
    end

    it 'lets you change the passphrase' do
      fill_in :secret_santa_passphrase, with: 'Avengers Only'
      expect { click_button 'Next' }.to change { secret_santa.reload.passphrase }.from(nil).to('Avengers Only')
    end

    it 'lets you add a participant' do
      click_link "Who's in?"
      click_link 'top-link-to-add-participant'

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_first_name')]").last.set('Incredible')
        all(:xpath, "//input[contains(@id,'_user_attributes_last_name')]").last.set('Hulk')
        all(:xpath, "//input[contains(@id,'_user_attributes_email')]").last.set('ihulk@avengers.com')
      end

      expect { click_button 'Next' }.to change { secret_santa.secret_santa_participants.count }.from(2).to(3)
    end

    it 'lets you add an exception' do
      click_link 'Any Exceptions?'
      select 'Thor', from: 'secret_santa_secret_santa_participants_attributes_0_secret_santa_participant_exceptions_attributes_0_exception_id'
      click_button 'Finish'
      expect(secret_santa_participant.secret_santa_participant_exceptions.count).to eq(1)
    end
  end
end
