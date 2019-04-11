FactoryBot.define do
    factory :review_bid, class: ReviewBid do
      team_id 1
      participant { Participant.first || association(:participant) }
      priority 1
    end
  end