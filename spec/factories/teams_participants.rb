FactoryBot.define do
  factory :teams_participant do
    team
    participant
    duty { nil }
  end
end 