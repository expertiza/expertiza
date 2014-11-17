FactoryGirl.define do
  factory :user do
    password              "password"
    password_confirmation "password"
    is_new_user           0

    factory :instructor do
      name  "instructor"
      email { "#{name}@mailinator.com" }
      role  { Role.find_by_name('instructor') }
    end

    # Can create many unique students
    factory :student do
      sequence(:name) { |n| "student#{n}" }
      email           { "#{name}@mailinator.com" }
      role            { Role.find_by_name('student') }
    end
  end

  factory :assignment do
    name                    "assignment"
    directory_path          { "#{name}_path" }
    submitter_count         0
    course_id               0
    instructor
    private                 0
    num_reviews             0
    num_review_of_reviews   0
    num_review_of_reviewers 0
    wiki_type               { WikiType.find_by_name('No') }
    num_reviewers           0
    max_team_size           3
    staggered_deadline      0
    review_topic_threshold  0
    copy_flag               0
    rounds_of_reviews       1
    microtask               0
    num_quiz_questions      0
    calculate_penalty       0
    is_penalty_calculated   0

    # Need to create a node after creating an assignment
    after(:create) { |assignment| assignment.create_node  }
  end

  factory :sign_up_topic do
    sequence(:topic_name) { |n| "topic#{n}" }
    assignment
    max_choosers          3
    category              { "#{topic_name}_category" }
    topic_identifier      1
    micropayment          0
  end
end
