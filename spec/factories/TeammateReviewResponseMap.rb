FactoryGirl.define do
  factory :teammatereviewresponsemap do |f|
    f.id { 6 }
    f.reviewer_id { 2 }
    f.reviewee_id { 1 }
    f.reviewed_object_id { 8 }
  end
end