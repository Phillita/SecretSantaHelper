FactoryGirl.define do
  factory :secret_santa_participant_exception do
    association :exception, factory: :secret_santa_participant
    secret_santa_participant
  end
end
