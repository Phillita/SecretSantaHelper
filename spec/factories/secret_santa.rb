FactoryGirl.define do
  factory :secret_santa do
    user
    name 'Test Secret Santa'
    send_file false
    send_email false
    test_run true
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

    factory :secret_santa_with_email, traits: [:send_an_email]
    factory :secret_santa_with_file, traits: [:send_a_file]
    factory :secret_santa_with_email_and_file, traits: [:send_an_email, :send_a_file]
  end
end
