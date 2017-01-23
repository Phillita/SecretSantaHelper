FactoryGirl.define do
  factory :secret_santa_participant, parent: :participant, class: 'SecretSantaParticipant' do
    association :participantable, factory: :secret_santa
  end
end
