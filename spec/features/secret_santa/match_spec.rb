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
      end

      scenario 'shows how it would randomly match up users' do
        click_link 'Run Test'

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
        click_link 'Run Test'
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
      expect { click_link 'Make Magic!' }.to change { secret_santa.reload.started? }.to(true)
      expect(page).to have_content('Matching successful!')

      visit secret_santum_path(secret_santa)
      expect(page).to have_content("This Secret Santa was started on #{secret_santa.reload.last_run_on}")

      click_link 'Results'

      expect(page).to have_content(black_widow.name, count: 1)
      expect(page).to have_content(thor.name, count: 1)
      expect(page).to have_content(captain.name, count: 1)
    end

    context 'has already run' do
      let!(:match1) do
        FactoryGirl.create(
          :secret_santa_participant_match,
          secret_santa_participant: secret_santa_participant,
          match: secret_santa_participant2,
          secret_santa: secret_santa
        )
      end
      let!(:match2) do
        FactoryGirl.create(
          :secret_santa_participant_match,
          secret_santa_participant: secret_santa_participant2,
          match: secret_santa_participant3,
          secret_santa: secret_santa
        )
      end
      let!(:match3) do
        FactoryGirl.create(
          :secret_santa_participant_match,
          secret_santa_participant: secret_santa_participant3,
          match: secret_santa_participant,
          secret_santa: secret_santa
        )
      end

      before(:each) do
        secret_santa.update(last_run_on: Time.now)
      end

      scenario 'can resend an email' do
        expect(SecretSantaMailer)
          .to receive(:participant).with(secret_santa_participant.id, secret_santa_participant2.name, nil).and_call_original
        visit secret_santum_path(secret_santa)
        click_link 'Results'
        within(".participant-#{secret_santa_participant.id}-result-row") do
          find(:css, 'span.glyphicon-envelope').click
        end
        expect(page).to have_content("Successfully resent email to #{secret_santa_participant.name}")
      end

      context 'and has passed the exchange date' do
        before(:each) do
          secret_santa.update(exchange_date: Time.now - 1.day)
        end

        scenario 'cannot resend an email' do
          visit secret_santum_path(secret_santa)
          click_link 'Results'
          within(".participant-#{secret_santa_participant.id}-result-row") do
            expect(page).to_not have_selector('span.glyphicon-envelope')
          end
        end
      end
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
      end

      scenario 'shows how it would randomly match up users' do
        click_link 'Run Test'

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
        click_link 'Run Test'
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
      expect { click_link 'Make Magic!' }.to change { secret_santa.reload.started? }.to(true)
      expect(page).to have_content('Matching successful!')

      visit secret_santum_path(secret_santa)
      expect(page).to have_content("This Secret Santa was started on #{secret_santa.reload.last_run_on}")

      click_link 'Results'

      expect(page).to have_content(black_widow.name, count: 1)
      expect(page).to have_content(thor.name, count: 1)
      expect(page).to have_content(captain.name, count: 1)
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
      expect { click_link 'Make Magic!' }.to change { secret_santa.reload.started? }.to(true)
      expect(page).to have_content('Matching successful!')

      visit secret_santum_path(secret_santa)
      expect(page).to have_content("This Secret Santa was started on #{secret_santa.reload.last_run_on}")

      click_link 'Results'

      expect(page).to have_content(black_widow.name, count: 1)
      expect(page).to have_content(thor.name, count: 1)
      expect(page).to have_content(captain.name, count: 1)
    end

    context 'has already run' do
      let!(:match1) do
        FactoryGirl.create(
          :secret_santa_participant_match,
          secret_santa_participant: secret_santa_participant,
          match: secret_santa_participant2,
          secret_santa: secret_santa
        )
      end
      let!(:match2) do
        FactoryGirl.create(
          :secret_santa_participant_match,
          secret_santa_participant: secret_santa_participant2,
          match: secret_santa_participant3,
          secret_santa: secret_santa
        )
      end
      let!(:match3) do
        FactoryGirl.create(
          :secret_santa_participant_match,
          secret_santa_participant: secret_santa_participant3,
          match: secret_santa_participant,
          secret_santa: secret_santa
        )
      end

      before(:each) do
        secret_santa.update(last_run_on: Time.now)
      end

      scenario 'can resend an email after the matches have been run' do
        expect(SecretSantaMailer)
          .to receive(:participant).with(secret_santa_participant.id, secret_santa_participant2.name, nil).and_call_original
        visit secret_santum_path(secret_santa)
        click_link 'Results'
        within(".participant-#{secret_santa_participant.id}-result-row") do
          find(:css, 'span.glyphicon-envelope').click
        end
      end

      context 'and has passed the exchange date' do
        before(:each) do
          secret_santa.update(exchange_date: Time.now - 1.day)
        end

        scenario 'cannot resend an email' do
          visit secret_santum_path(secret_santa)
          click_link 'Results'
          within(".participant-#{secret_santa_participant.id}-result-row") do
            expect(page).to_not have_selector('span.glyphicon-envelope')
          end
        end
      end
    end
  end
end
