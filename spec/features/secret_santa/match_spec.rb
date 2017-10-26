# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Matching users in the Secret Santa', js: true do
  let(:secret_santa) do
    FactoryGirl.create(:secret_santa_with_email, user: black_widow, name: 'Avengers First Secret Santa')
  end
  let!(:secret_santa_participant) do
    FactoryGirl.create(:secret_santa_participant, user: black_widow, participantable: secret_santa)
  end
  let!(:secret_santa_participant2) do
    FactoryGirl.create(:secret_santa_participant, user: thor, participantable: secret_santa)
  end
  let!(:secret_santa_participant3) do
    FactoryGirl.create(:secret_santa_participant, user: captain, participantable: secret_santa)
  end

  context 'as a guest user' do
    let(:black_widow) { FactoryGirl.create(:user_guest, first_name: 'B', last_name: 'W', email: 'bw@avengers.com') }
    let(:thor) { FactoryGirl.create(:user_guest, first_name: 'Thor', last_name: '', email: 'thor@avengers.com') }
    let(:captain) do
      FactoryGirl.create(:user_guest, first_name: 'Captain', last_name: 'America', email: 'camerica@avengers.com')
    end

    context 'with the test flag on' do
      before(:each) do
        visit secret_santum_path(secret_santa)
        check 'secret_santa_test_run'
      end

      scenario 'shows how it would randomly match up users' do
        click_button 'Make Magic!'

        expect(page).to have_content('Matching successful!')

        expect(page).to have_content(black_widow.name, count: 2)
        expect(page).to have_content(thor.name, count: 2)
        expect(page).to have_content(captain.name, count: 2)

        expect(secret_santa.secret_santa_participant_matches.where(test: true).count).to eq(3)
      end

      scenario 'shows error message if it not able to match all participants' do
        FactoryGirl.create(
          :secret_santa_participant_exception,
          exception: secret_santa_participant3,
          secret_santa_participant: secret_santa_participant
        )
        FactoryGirl.create(
          :secret_santa_participant_exception,
          exception: secret_santa_participant,
          secret_santa_participant: secret_santa_participant3
        )
        click_button 'Make Magic!'
        expect(page).to have_content(
          "Failed to match all participants. It's possible that not all participants can be matched. Please try again."
        )
      end
    end

    scenario 'sends emails to all participants matched' do
      expect(SecretSantaMailer)
        .to receive(:participant).with(secret_santa_participant.id, a_kind_of(String), nil).and_call_original
      expect(SecretSantaMailer)
        .to receive(:participant).with(secret_santa_participant2.id, a_kind_of(String), nil).and_call_original
      expect(SecretSantaMailer)
        .to receive(:participant).with(secret_santa_participant3.id, a_kind_of(String), nil).and_call_original
      allow(Kernel).to receive(:sleep).with(1).and_return(true)
      visit secret_santum_path(secret_santa)
      expect { click_button 'Make Magic!' }.to change { secret_santa.reload.started? }.to(true)
      expect(page).to have_content('Matching successful!')

      visit secret_santum_path(secret_santa)
      expect(page).to have_content("This Secret Santa was started on #{secret_santa.reload.last_run_on}")
    end
  end

  context 'as a logged in user' do
    let(:black_widow) { FactoryGirl.create(:user, first_name: 'B', last_name: 'W', email: 'bw@avengers.com') }
    let(:thor) { FactoryGirl.create(:user, first_name: 'Thor', last_name: '', email: 'thor@avengers.com') }
    let(:captain) do
      FactoryGirl.create(:user, first_name: 'Captain', last_name: 'America', email: 'camerica@avengers.com')
    end

    context 'with the test flag on' do
      before(:each) do
        visit secret_santum_path(secret_santa)
        check 'secret_santa_test_run'
      end

      scenario 'shows how it would randomly match up users' do
        click_button 'Make Magic!'

        expect(page).to have_content('Matching successful!')

        expect(page).to have_content(black_widow.name, count: 2)
        expect(page).to have_content(thor.name, count: 2)
        expect(page).to have_content(captain.name, count: 2)

        expect(secret_santa.secret_santa_participant_matches.where(test: true).count).to eq(3)
      end

      scenario 'shows error message if it not able to match all participants' do
        FactoryGirl.create(
          :secret_santa_participant_exception,
          exception: secret_santa_participant3,
          secret_santa_participant: secret_santa_participant
        )
        FactoryGirl.create(
          :secret_santa_participant_exception,
          exception: secret_santa_participant,
          secret_santa_participant: secret_santa_participant3
        )
        click_button 'Make Magic!'
        expect(page).to have_content(
          "Failed to match all participants. It's possible that not all participants can be matched. Please try again."
        )
      end
    end

    scenario 'sends emails to all participants matched' do
      expect(SecretSantaMailer)
        .to receive(:participant).with(secret_santa_participant.id, a_kind_of(String), nil).and_call_original
      expect(SecretSantaMailer)
        .to receive(:participant).with(secret_santa_participant2.id, a_kind_of(String), nil).and_call_original
      expect(SecretSantaMailer)
        .to receive(:participant).with(secret_santa_participant3.id, a_kind_of(String), nil).and_call_original
      allow(Kernel).to receive(:sleep).with(1).and_return(true)
      visit secret_santum_path(secret_santa)
      expect { click_button 'Make Magic!' }.to change { secret_santa.reload.started? }.to(true)
      expect(page).to have_content('Matching successful!')

      visit secret_santum_path(secret_santa)
      expect(page).to have_content("This Secret Santa was started on #{secret_santa.reload.last_run_on}")
    end
  end
end
