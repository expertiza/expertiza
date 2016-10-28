FactoryGirl.define do
  factory :FeedbackResponseMap do |f|
    f.reviewed_object_id { 100 }
    f.reviewer_id { 200 }
    f.reviewee_id { 1 }
  end
end
