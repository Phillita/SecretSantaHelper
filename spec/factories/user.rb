# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    sequence(:email) { |n| "email_#{n}@example.com" }
    password '12345678'
    password_confirmation '12345678'
  end
end
