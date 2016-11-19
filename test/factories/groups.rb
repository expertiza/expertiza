FactoryGirl.define do
  factory :group do
    isAnonymous false
name "MyString"
parent_id 1
type ""
comments_for_advertisement "MyText"
advertise_for_partners false
  end

end
