# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecretSantaHelper, type: :helper do
  describe 'secret_santa_wizard_step' do
    let(:step_number) { 1 }
    let(:text_step) { 'test' }

    it 'returns a path for a wizard step using a number' do
      expect(secret_santa_wizard_step(step_number)).to eq("#{SecretSantaHelper::DEFAULT_WIZARD_VIEW_PATH}#{step_number}")
    end

    it 'returns a path for a wizard step using a string' do
      expect(secret_santa_wizard_step(text_step)).to eq("#{SecretSantaHelper::DEFAULT_WIZARD_VIEW_PATH}#{text_step}")
    end

    it 'raises an error if no step is passed' do
      expect { secret_santa_wizard_step(nil) }.to raise_error(ArgumentError)
    end
  end

  describe 'exceptions_for_secret_santa_participant' do
    let(:participant) { FactoryGirl.create(:secret_santa_participant) }

    let(:participant_exception) do
      FactoryGirl.create(:secret_santa_participant, participantable: participant.participantable).tap do |p2|
        FactoryGirl.create(:secret_santa_participant_exception, secret_santa_participant: participant, exception: p2)
      end
    end

    it 'returns a blank array of participants for a participant without exceptions' do
      expect(exceptions_for_secret_santa_participant(participant.id, participant.participantable)).to be_blank
    end

    it 'should return a list of participants who are exceptions for the participant' do
      expect(exceptions_for_secret_santa_participant(participant.id, participant.participantable)).to eq([participant_exception])
    end

    it 'should raise an error without an id' do
      expect { exceptions_for_secret_santa_participant(nil, participant.participantable) }.to raise_error(ArgumentError)
    end

    it 'should raise an error without an secret santa' do
      expect { exceptions_for_secret_santa_participant(participant.id, nil) }.to raise_error(ArgumentError)
    end
  end

  describe 'max_secret_santa_step' do
    it 'returns the max wizard step' do
      expect(max_secret_santa_step).to eq(SecretSantaHelper::MAX_WIZARD_STEP_NUMBER)
    end
  end

  describe 'active?' do
    it "returns #{SecretSantaHelper::WIZARD_ACTIVE_TAB_CLASS} if the 2 args match" do
      expect(active?(nil, nil)).to eq(SecretSantaHelper::WIZARD_ACTIVE_TAB_CLASS)
      expect(active?(1, 1)).to eq(SecretSantaHelper::WIZARD_ACTIVE_TAB_CLASS)
      expect(active?('test', 'test')).to eq(SecretSantaHelper::WIZARD_ACTIVE_TAB_CLASS)
      expect(active?('', '')).to eq(SecretSantaHelper::WIZARD_ACTIVE_TAB_CLASS)
    end

    it 'returns a blank string if the 2 args do not match' do
      expect(active?(nil, 1)).to be_blank
      expect(active?(1, '1')).to be_blank
      expect(active?(2, 1)).to be_blank
      expect(active?('test', '1')).to be_blank
      expect(active?('test', '')).to be_blank
    end
  end

  describe 'autofocus_object?' do
    it 'returns true with a nil id' do
      expect(autofocus_object?(nil, 1)).to be_truthy
      expect(autofocus_object?(nil, nil)).to be_truthy
      expect(autofocus_object?(nil, '1')).to be_truthy
    end

    it 'returns true with a matching id' do
      expect(autofocus_object?(1, 1)).to be_truthy
      expect(autofocus_object?('1', 1)).to be_truthy
      expect(autofocus_object?('1', '1')).to be_truthy
      expect(autofocus_object?(1, '1')).to be_truthy
    end

    it 'returns false with a mismatched id' do
      expect(autofocus_object?(2, 1)).to be_falsey
      expect(autofocus_object?('2', 1)).to be_falsey
      expect(autofocus_object?('2', '1')).to be_falsey
      expect(autofocus_object?(2, '1')).to be_falsey
      expect(autofocus_object?(2, 3)).to be_falsey
      expect(autofocus_object?(1, nil)).to be_falsey
    end
  end
end
