# Factory to create dummy data
# Used by student_submission_spec.rb

FactoryGirl.define do
  factory :user do
    name 'student1300'
    role_id 1
    password 'student1300'
    password_confirmation 'student1300'
    email 'a@a.com'
  end
end