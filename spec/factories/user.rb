# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    sequence(:first_name) { |n| "FirstName#{n}" }
    sequence(:last_name) { |n| "LastName#{n}" }
    sequence(:email) { |n| "email_#{n}@example.com" }
    password 'Passw0rd1'
    password_confirmation 'Passw0rd1'

    trait :guest do
      guest Time.now
      password nil
      password_confirmation nil
    end

    factory :user_guest, traits: [:guest]
  end
end
