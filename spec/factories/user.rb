# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    sequence(:first_name) { |n| "FirstName#{n}" }
    sequence(:last_name) { |n| "LastName#{n}" }
    sequence(:email) { |n| "email_#{n}@example.com" }
    password '12345678'
    password_confirmation '12345678'
  end
end
