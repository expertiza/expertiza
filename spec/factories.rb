require 'factory_girl_rails'

FactoryGirl.define do
 
  #instructor for assignment
  factory :user do
    sequence(:name) { |n| "NewName #{n}" }
    fullname {"test_user"}
    email {"sjolly@ncsu.edu"}
    parent_id =1
    is_new_user=true
  end

  
  # Factory for Assignment with name
  factory :assignment do
    #name {'OSS'}
    sequence(:name) { |n| "OS #{n}" }
    submitter_count {3}
    is_coding_assignment {true}
    microtask {true}
    review_assignment_strategy {'Auto-Selected'}
    association :instructor, factory: :user
  end

  # Factory for Assignment without name
  factory :assignment_without_name, class: Assignment do
    name {}
    submitter_count {3}
    is_coding_assignment {true}
    microtask {true}
    review_assignment_strategy {'Auto-Selected'}
    association :instructor, factory: :user
  end

  # Factory for Assignment Team
  
  factory :assignmentTeam, class: AssignmentTeam do
 
  end

  factory :signed_up_topic, class: SignUpTopic do
    topic_name {'TestApplication'}
    topic_identifier {'A1234B1234'}
    #association :assignment, factory: :assignment
    assignment
  end
end 
