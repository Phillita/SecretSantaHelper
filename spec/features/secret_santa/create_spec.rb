# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Creating a Secret Santa', js: true do
  context 'as a guest user' do
    scenario 'from the dashboard' do
      visit root_path
      click_link 'secret-santa-start'
      expect(page.current_path).to eq(secret_santa_path)
      click_link 'Create one now!'
      expect(page.current_path).to eq(secret_santa_path)

      expect(page).to have_content(:h1, 'New Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'First Steps')

      expect(page).to have_content(:h4, 'What would you like to call it & When is it hapenning?')
      expect(page).to have_content(:h5, 'Why?', count: 2)
      expect(page).to have_content(:p, 'The name will help you remember this Secret Santa.')
      expect(page).to have_content(:p, 'Emails sent to your participants will have this title in it.')
      expect(page).to have_content(:p, 'Results will be displayed after the exchange date has been passed.')

      expect(page).to have_content(:h4, 'Who are you?')

      expect(page).to have_content(:h4, 'Secure It!')
      expect(page).to have_content(:p, "Currently you are a guest on the site. If you'd rather other people not be able to find and enter your Secret Santa, give it a passphrase!")
      expect(page).to have_content(:p, 'Guidelines:')
      expect(page).to have_content(:li, 'Minimum of 6 characters.')
      expect(page).to have_content(:li, 'Use letters numbers and symbols.')
      expect(page).to have_content(:li, "Make sure it's memerable!")

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_content(:p, "User first name can't be blank")
      expect(page).to have_content(:p, "User email can't be blank")
      expect(page).to have_content(:p, 'User email is invalid')

      fill_in :secret_santa_name, with: 'Avengers First Secret Santa'
      fill_in :secret_santa_user_attributes_last_name, with: 'America'

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_selector("input[value='Avengers First Secret Santa']")
      expect(page).to have_selector("input[value='America']")
      expect(page).to have_content(:p, "User first name can't be blank")
      expect(page).to have_content(:p, "User email can't be blank")
      expect(page).to have_content(:p, 'User email is invalid')

      fill_in :secret_santa_user_attributes_first_name, with: 'Captain'
      fill_in :secret_santa_user_attributes_email, with: 'camerica@avengers.com'

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, "Who's joining you?")

      click_button 'Back'
      expect(page).to have_content(:h2, 'First Steps')
      click_button 'Next'
      expect(page).to have_content(:h2, "Who's joining you?")

      expect(page).to have_selector("input[value='Captain']")
      expect(page).to have_selector("input[value='America']")
      expect(page).to have_selector("input[value='camerica@avengers.com']")

      click_link 'top-link-to-add-participant'

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_content(:p, "Secret santa participants user first name can't be blank")
      expect(page).to have_content(:p, "Secret santa participants user email can't be blank")
      expect(page).to have_content(:p, 'Secret santa participants user email is invalid')

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_first_name')]").last.set('Iron')
      end

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_content(:p, "Secret santa participants user email can't be blank")
      expect(page).to have_content(:p, 'Secret santa participants user email is invalid')

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_last_name')]").last.set('Man')
        all(:xpath, "//input[contains(@id,'_user_attributes_email')]").last.set('iman@avengers.com')
      end

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'Any Exceptions?')

      click_button 'Back'

      click_link 'bottom-link-to-add-participant'

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_first_name')]").last.set('Incredible')
        all(:xpath, "//input[contains(@id,'_user_attributes_last_name')]").last.set('Hulk')
        all(:xpath, "//input[contains(@id,'_user_attributes_email')]").last.set('ihulk@avengers.com')
      end

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'Any Exceptions?')
      expect(page).to have_content(:h4, 'Captain America')
      expect(page).to have_content(:h4, 'Iron Man')
      expect(page).to have_content(:h4, 'Incredible Hulk')

      # Iron man doesn't want to buy for the Captain
      select 'Captain America', from: 'secret_santa_secret_santa_participants_attributes_1_secret_santa_participant_exceptions_attributes_0_exception_id'

      click_button 'Finish'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).not_to have_css('div .alert.alert-success')
      expect(page).to have_content(:h1, 'Avengers First Secret Santa')

      created_secret_santa = SecretSanta.first
      expect(page.current_path).to eq(secret_santum_path(created_secret_santa))

      expect(created_secret_santa.secret_santa_participants.count).to eq(3)
      expect(created_secret_santa.secret_santa_participants.second.secret_santa_participant_exceptions.count).to eq(1)
    end

    scenario 'from the new page' do
      visit new_secret_santum_path

      expect(page).to have_content(:h1, 'New Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'First Steps')

      expect(page).to have_content(:h4, 'What would you like to call it & When is it hapenning?')
      expect(page).to have_content(:h5, 'Why?', count: 2)
      expect(page).to have_content(:p, 'The name will help you remember this Secret Santa.')
      expect(page).to have_content(:p, 'Emails sent to your participants will have this title in it.')
      expect(page).to have_content(:p, 'Results will be displayed after the exchange date has been passed.')

      expect(page).to have_content(:h4, 'Who are you?')

      expect(page).to have_content(:h4, 'Secure It!')
      expect(page).to have_content(:p, "Currently you are a guest on the site. If you'd rather other people not be able to find and enter your Secret Santa, give it a passphrase!")
      expect(page).to have_content(:p, 'Guidelines:')
      expect(page).to have_content(:li, 'Minimum of 6 characters.')
      expect(page).to have_content(:li, 'Use letters numbers and symbols.')
      expect(page).to have_content(:li, "Make sure it's memerable!")

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_content(:p, "User first name can't be blank")
      expect(page).to have_content(:p, "User email can't be blank")
      expect(page).to have_content(:p, 'User email is invalid')

      fill_in :secret_santa_name, with: 'Avengers First Secret Santa'
      fill_in :secret_santa_user_attributes_last_name, with: 'America'

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_selector("input[value='Avengers First Secret Santa']")
      expect(page).to have_selector("input[value='America']")
      expect(page).to have_content(:p, "User first name can't be blank")
      expect(page).to have_content(:p, "User email can't be blank")
      expect(page).to have_content(:p, 'User email is invalid')

      fill_in :secret_santa_user_attributes_first_name, with: 'Captain'
      fill_in :secret_santa_user_attributes_email, with: 'camerica@avengers.com'

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, "Who's joining you?")

      click_button 'Back'
      expect(page).to have_content(:h2, 'First Steps')
      click_button 'Next'
      expect(page).to have_content(:h2, "Who's joining you?")

      expect(page).to have_selector("input[value='Captain']")
      expect(page).to have_selector("input[value='America']")
      expect(page).to have_selector("input[value='camerica@avengers.com']")

      click_link 'top-link-to-add-participant'

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_content(:p, "Secret santa participants user first name can't be blank")
      expect(page).to have_content(:p, "Secret santa participants user email can't be blank")
      expect(page).to have_content(:p, 'Secret santa participants user email is invalid')

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_first_name')]").last.set('Iron')
      end

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_content(:p, "Secret santa participants user email can't be blank")
      expect(page).to have_content(:p, 'Secret santa participants user email is invalid')

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_last_name')]").last.set('Man')
        all(:xpath, "//input[contains(@id,'_user_attributes_email')]").last.set('iman@avengers.com')
      end

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'Any Exceptions?')

      click_button 'Back'

      click_link 'top-link-to-add-participant'

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_first_name')]").last.set('Incredible')
        all(:xpath, "//input[contains(@id,'_user_attributes_last_name')]").last.set('Hulk')
        all(:xpath, "//input[contains(@id,'_user_attributes_email')]").last.set('ihulk@avengers.com')
      end

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'Any Exceptions?')
      expect(page).to have_content(:h4, 'Captain America')
      expect(page).to have_content(:h4, 'Iron Man')
      expect(page).to have_content(:h4, 'Incredible Hulk')

      # Iron man doesn't want to buy for the Captain
      select 'Captain America', from: 'secret_santa_secret_santa_participants_attributes_1_secret_santa_participant_exceptions_attributes_0_exception_id'

      click_button 'Finish'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).not_to have_css('div .alert.alert-success')
      expect(page).to have_content(:h1, 'Avengers First Secret Santa')

      created_secret_santa = SecretSanta.first
      expect(page.current_path).to eq(secret_santum_path(created_secret_santa))

      expect(created_secret_santa.secret_santa_participants.count).to eq(3)
      expect(created_secret_santa.secret_santa_participants.second.secret_santa_participant_exceptions.count).to eq(1)
    end
  end

  context 'as a logged in user' do
    let!(:user) { FactoryGirl.create(:user, first_name: 'Captain', last_name: 'America', email: 'camerica@avengers.com') }

    before(:each) { login_as(user, scope: :user) }

    scenario 'from the dashboard' do
      visit root_path
      click_link 'secret-santa-start'
      expect(page.current_path).to eq(secret_santa_path)
      click_link 'Create one now!'
      expect(page.current_path).to eq(secret_santa_path)

      expect(page).to have_content(:h1, 'New Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'First Steps')

      expect(page).to have_content(:h4, 'What would you like to call it & When is it hapenning?')
      expect(page).to have_content(:h5, 'Why?', count: 2)
      expect(page).to have_content(:p, 'The name will help you remember this Secret Santa.')
      expect(page).to have_content(:p, 'Emails sent to your participants will have this title in it.')
      expect(page).to have_content(:p, 'Results will be displayed after the exchange date has been passed.')

      expect(page).to have_content(:h4, 'Who are you?')

      expect(page).to have_content(:h4, 'Secure It!')
      expect(page).to have_content(:p, "Currently you are a guest on the site. If you'd rather other people not be able to find and enter your Secret Santa, give it a passphrase!")
      expect(page).to have_content(:p, 'Guidelines:')
      expect(page).to have_content(:li, 'Minimum of 6 characters.')
      expect(page).to have_content(:li, 'Use letters numbers and symbols.')
      expect(page).to have_content(:li, "Make sure it's memerable!")

      expect(page).to have_selector("input[value='Captain']")
      expect(page).to have_selector("input[value='America']")
      expect(page).to have_selector("input[value='camerica@avengers.com']")
      fill_in :secret_santa_name, with: 'Avengers First Secret Santa'

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, "Who's joining you?")

      click_button 'Back'
      expect(page).to have_content(:h2, 'First Steps')
      click_button 'Next'
      expect(page).to have_content(:h2, "Who's joining you?")

      expect(page).to have_selector("input[value='Captain']")
      expect(page).to have_selector("input[value='America']")
      expect(page).to have_selector("input[value='camerica@avengers.com']")

      click_link 'top-link-to-add-participant'

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_content(:p, "Secret santa participants user first name can't be blank")
      expect(page).to have_content(:p, "Secret santa participants user email can't be blank")
      expect(page).to have_content(:p, 'Secret santa participants user email is invalid')

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_first_name')]").last.set('Iron')
      end

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_content(:p, "Secret santa participants user email can't be blank")
      expect(page).to have_content(:p, 'Secret santa participants user email is invalid')

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_last_name')]").last.set('Man')
        all(:xpath, "//input[contains(@id,'_user_attributes_email')]").last.set('iman@avengers.com')
      end

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'Any Exceptions?')

      click_button 'Back'

      click_link 'top-link-to-add-participant'

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_first_name')]").last.set('Incredible')
        all(:xpath, "//input[contains(@id,'_user_attributes_last_name')]").last.set('Hulk')
        all(:xpath, "//input[contains(@id,'_user_attributes_email')]").last.set('ihulk@avengers.com')
      end

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'Any Exceptions?')
      expect(page).to have_content(:h4, 'Captain America')
      expect(page).to have_content(:h4, 'Iron Man')
      expect(page).to have_content(:h4, 'Incredible Hulk')

      # Iron man doesn't want to buy for the Captain
      select 'Captain America', from: 'secret_santa_secret_santa_participants_attributes_1_secret_santa_participant_exceptions_attributes_0_exception_id'

      click_button 'Finish'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).not_to have_css('div .alert.alert-success')
      expect(page).to have_content(:h1, 'Avengers First Secret Santa')

      created_secret_santa = SecretSanta.first
      expect(page.current_path).to eq(secret_santum_path(created_secret_santa))

      expect(created_secret_santa.secret_santa_participants.count).to eq(3)
      expect(created_secret_santa.secret_santa_participants.second.secret_santa_participant_exceptions.count).to eq(1)
    end

    scenario 'from the new page' do
      visit new_secret_santum_path

      expect(page).to have_content(:h1, 'New Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'First Steps')

      expect(page).to have_content(:h4, 'What would you like to call it & When is it hapenning?')
      expect(page).to have_content(:h5, 'Why?', count: 2)
      expect(page).to have_content(:p, 'The name will help you remember this Secret Santa.')
      expect(page).to have_content(:p, 'Emails sent to your participants will have this title in it.')
      expect(page).to have_content(:p, 'Results will be displayed after the exchange date has been passed.')

      expect(page).to have_content(:h4, 'Who are you?')

      expect(page).to have_content(:h4, 'Secure It!')
      expect(page).to have_content(:p, "Currently you are a guest on the site. If you'd rather other people not be able to find and enter your Secret Santa, give it a passphrase!")
      expect(page).to have_content(:p, 'Guidelines:')
      expect(page).to have_content(:li, 'Minimum of 6 characters.')
      expect(page).to have_content(:li, 'Use letters numbers and symbols.')
      expect(page).to have_content(:li, "Make sure it's memerable!")

      expect(page).to have_selector("input[value='Captain']")
      expect(page).to have_selector("input[value='America']")
      expect(page).to have_selector("input[value='camerica@avengers.com']")
      fill_in 'secret_santa_name', with: 'Avengers First Secret Santa'

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, "Who's joining you?")

      click_button 'Back'
      expect(page).to have_content(:h2, 'First Steps')
      click_button 'Next'
      expect(page).to have_content(:h2, "Who's joining you?")

      expect(page).to have_selector("input[value='Captain']")
      expect(page).to have_selector("input[value='America']")
      expect(page).to have_selector("input[value='camerica@avengers.com']")

      click_link 'top-link-to-add-participant'

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_content(:p, "Secret santa participants user first name can't be blank")
      expect(page).to have_content(:p, "Secret santa participants user email can't be blank")
      expect(page).to have_content(:p, 'Secret santa participants user email is invalid')

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_first_name')]").last.set('Iron')
      end

      click_button 'Next'

      expect(page).to have_css('div .alert.alert-danger')
      expect(page).to have_content(:p, "Secret santa participants user email can't be blank")
      expect(page).to have_content(:p, 'Secret santa participants user email is invalid')

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_last_name')]").last.set('Man')
        all(:xpath, "//input[contains(@id,'_user_attributes_email')]").last.set('iman@avengers.com')
      end

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'Any Exceptions?')

      click_button 'Back'

      click_link 'top-link-to-add-participant'

      within('#secret_santa_participants') do
        all(:xpath, "//input[contains(@id,'_user_attributes_first_name')]").last.set('Incredible')
        all(:xpath, "//input[contains(@id,'_user_attributes_last_name')]").last.set('Hulk')
        all(:xpath, "//input[contains(@id,'_user_attributes_email')]").last.set('ihulk@avengers.com')
      end

      click_button 'Next'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).to have_link('Avengers First Secret Santa')
      expect(page).to have_content(:li, 'First Steps')
      expect(page).to have_content(:li, "Who's in?")
      expect(page).to have_content(:li, 'Any Exceptions?')
      expect(page).to have_content(:h2, 'Any Exceptions?')
      expect(page).to have_content(:h4, 'Captain America')
      expect(page).to have_content(:h4, 'Iron Man')
      expect(page).to have_content(:h4, 'Incredible Hulk')

      # Iron man doesn't want to buy for the Captain
      select 'Captain America', from: 'secret_santa_secret_santa_participants_attributes_1_secret_santa_participant_exceptions_attributes_0_exception_id'

      click_button 'Finish'

      expect(page).not_to have_css('div .alert.alert-danger')
      expect(page).not_to have_css('div .alert.alert-success')
      expect(page).to have_content(:h1, 'Avengers First Secret Santa')

      created_secret_santa = SecretSanta.first
      expect(page.current_path).to eq(secret_santum_path(created_secret_santa))

      expect(created_secret_santa.secret_santa_participants.count).to eq(3)
      expect(created_secret_santa.secret_santa_participants.second.secret_santa_participant_exceptions.count).to eq(1)
    end
  end
end
