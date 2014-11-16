FactoryGirl.define do
  factory :student, class: User do
    sequence(:name)       { |n| "student#{n}" }
    sequence(:email)      { |n| "student#{n}@mailinator.com"}
    password              "password"
    password_confirmation "password"
    role                  { Role.find_by_name('student') }
    is_new_user           0

  #  association :role, factory: :student_role
  end
end
