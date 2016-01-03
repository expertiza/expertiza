
 FactoryGirl.define do
    sequence (:name) do |n| 
      n=n%3
      "student206#{n+4}"
    end
  end

FactoryGirl.define do

  factory :role ,class: Role do
    name "Student"
    parent_id  1 
    description  "" 
    cache nil     
  end

  factory :student, class: User do
    name
    crypted_password "e83023eae8ec13ce0ed71efce1a3c4bbe23fc21c" 
    role { Role.first || association(:role)}
    password_salt  "XwDiWxpNugmGzpCNib" 
    fullname "2064, student"
    email "expertiza@mailinator.com"
    parent_id  1
    private_by_default  false 
    mru_directory_path  nil
    email_on_review  true
    email_on_submission  true 
    email_on_review_of_review  true
    is_new_user false
    master_permission_granted 0 
    handle "handle"
    leaderboard_privacy false 
    digital_certificate  nil 
    persistence_token  "31a60e1c3ae74ed6000750006e3347e8a7e092ff1dd38d0036..." 
    timezonepref nil
    public_key nil
    copy_of_emails  false
  end
     
  factory :course ,class:Course do
    name "CSC517, test"
    instructor_id nil
    directory_path "csc517/test"
    info "Object-Oriented Languages and Systems"
    private true
    institutions_id nil
  end

  factory :assignment ,class:Assignment do
    name "final2"
    directory_path "final_test" 
    submitter_count 0 
    course
    instructor_id nil
    private false
    num_reviews 0
    num_review_of_reviews 0
    num_review_of_reviewers 0
    reviews_visible_to_all false
    num_reviewers 0
    spec_location "https://expertiza.ncsu.edu/"
    max_team_size 3
    staggered_deadline false
    allow_suggestions false
    days_between_submissions nil
    review_assignment_strategy "Auto-Selected"
    max_reviews_per_submission nil
    review_topic_threshold 0
    copy_flag false
    rounds_of_reviews 1
    microtask false
    require_quiz false
    num_quiz_questions 0
    is_coding_assignment false
    is_intelligent false
    calculate_penalty false
    late_policy_id nil
    is_penalty_calculated false
    show_teammate_reviews true
    availability_flag true
    use_bookmark false
    can_review_same_topic true
    can_choose_topic_to_review true
  end

  factory :topics, class:SignUpTopic do
    topic_name "Hello world!"
    assignment{ Assignment.first || association(:assignment)}
    max_choosers 1
    category nil
    topic_identifier "1"
    micropayment 0 
    private_to nil
  end   

  factory :participants, class:Participant do
    can_submit true
    can_review true
    assignment { Assignment.first || association(:assignment)}  
    association :user, :factory => :student,strategy: :build   
    submitted_at nil
    permission_granted nil
    penalty_accumulated 0
    grade nil 
    type "AssignmentParticipant" 
    handle "handle"
    time_stamp nil
    digital_signature nil
    duty nil 
    can_take_quiz true
  end 

  factory :due_date ,class:DueDate do
    due_at  "2015-12-30 23:30:12"
    association :deadline_type, :factory => :deadline_type, strategy: :build 
    assignment { Assignment.first || association(:assignment)}   
    submission_allowed_id nil
    review_allowed_id  nil
    resubmission_allowed_id  nil
    rereview_allowed_id  nil
    review_of_review_allowed_id  nil
    round  1
    flag  false
    threshold  1
    delayed_job_id  nil
    deadline_name  nil
    description_url nil
    quiz_allowed_id nil
    teammate_review_allowed_id nil
  end

  factory :deadline_type ,class:DeadlineType do
    #name can be overridden in RSpec test.
    name  "drop_topic"
  end     

  factory :deadline_right ,class:DeadlineType do
    name  "No"
  end  

  factory :assignment_node ,class:AssignmentNode do
    parent_id 1
    node_object_id 1
    type "AssignmentNode"
  end  
end