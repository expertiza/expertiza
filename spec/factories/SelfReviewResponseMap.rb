FactoryGirl.define do
  factory :SelfReviewResponseMap do |f|
    f.reviewed_object_id { 100 }
    f.reviewee_id { 1 }
  end
end