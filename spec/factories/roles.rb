FactoryGirl.define do
  factory :student_role, class: Role do |f|
    f.id "1"
    f.name "student"
    f.description "student"
  end
  factory :instructor_role, class: Role do |f|
    f.id "2"
    f.name "instructor"
    f.description "instructor"
  end
end
