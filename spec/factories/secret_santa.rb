# frozen_string_literal: true

FactoryGirl.define do
  factory :secret_santa do
    user
    sequence(:name) { |n| "Test Secret Santa #{n}" }
    send_file false
    send_email false
    test_run nil
    last_run_on nil
    passphrase nil

    trait :send_a_file do
      send_file true
      filename 'Test File Name'
      file_content 'Test File Content'
    end

    trait :send_an_email do
      send_email true
      email_subject 'Test Email Subject'
      email_content 'Test Email Content'
    end

    trait :test_on do
      test_run DateTime.current
    end

    trait :secure do
      passphrase 'Test'
    end

    trait :completed do
      last_run_on DateTime.current - 2.days
      exchange_date DateTime.current - 1.day
    end

    trait :started do
      last_run_on DateTime.current
    end

    factory :secret_santa_test, traits: [:test_on]
    factory :secret_santa_completed, traits: [:completed]
    factory :secret_santa_started, traits: [:started]
    factory :secret_santa_secure, traits: [:secure]
    factory :secret_santa_with_email, traits: [:send_an_email]
    factory :secret_santa_with_file, traits: [:send_a_file]
    factory :secret_santa_with_email_and_file, traits: [:send_an_email, :send_a_file]
  end
end
