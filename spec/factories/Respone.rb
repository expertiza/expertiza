FactoryGirl.define do
  factory :Response do |f|
    f.map_id { 100 }
    f.additional_comment { "response working propperly" }
    f.round { "1" }
  end
end
