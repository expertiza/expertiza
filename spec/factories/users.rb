FactoryGirl.define do
  factory :student, class: User do |f|
    f.id "1"
    f.name "student"
    f.email "student@domain.com"
    f.password "abcde"
    f.password_confirmation "abcde"
    f.role_id "1"
    f.is_new_user "1"
    f.timezonepref "Eastern Time (US & Canada)"
  end
  factory :instructor, class: User do |f|
    f.id "2"
    f.name "instructor"
    f.email "student@domain.com"
    f.password "abcde"
    f.password_confirmation "abcde"
    f.role_id "2"
    f.is_new_user "1"
    f.timezonepref "Eastern Time (US & Canada)"
  end
end

