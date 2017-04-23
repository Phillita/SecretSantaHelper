# frozen_string_literal: true

FactoryGirl.define do
  factory :secret_santa_participant_match do
    association :match, factory: :secret_santa_participant
    secret_santa_participant
    test false
  end
end
