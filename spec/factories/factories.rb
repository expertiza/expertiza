FactoryGirl.define do
  factory :role_of_administrator, class: Role do
    name 'Administrator'
    parent_id nil
    description ''
  end

  factory :role_of_student, class: Role do
    name "Student"
    parent_id  nil
    description ""
  end

  factory :role_of_instructor, class: Role do
    name "Instructor"
    parent_id nil
    description ""
  end

  factory :role_of_teaching_assistant, class: Role do
    name "Teaching Assistant"
    parent_id nil
    description ""
  end

  factory :admin, class: User do
    sequence(:name) {|n| "admin#{n}" }
    role { Role.where(name: 'Administrator').first || association(:role_of_administrator) }
    password "password"
    password_confirmation "password"
    sequence(:fullname) {|n| "#{n}, administrator" }
    email "expertiza@mailinator.com"
    parent_id 1
    private_by_default  false
    mru_directory_path  nil
    email_on_review true
    email_on_submission true
    email_on_review_of_review true
    is_new_user false
    master_permission_granted 0
    handle "handle"
    digital_certificate nil
    timezonepref nil
    public_key nil
    copy_of_emails  false
  end

  factory :student, class: User do
    # Zhewei: In order to keep students the same names (2064, 2065, 2066) before each example.
    sequence(:name) {|n| n = n % 3; "student206#{n + 4}" }
    role { Role.where(name: 'Student').first || association(:role_of_student) }
    password "password"
    password_confirmation "password"
    sequence(:fullname) {|n| n = n % 3; "206#{n + 4}, student" }
    email "expertiza@mailinator.com"
    parent_id 1
    private_by_default  false
    mru_directory_path  nil
    email_on_review true
    email_on_submission true
    email_on_review_of_review true
    is_new_user false
    master_permission_granted 0
    handle "handle"
    digital_certificate nil
    timezonepref 'Eastern Time (US & Canada)'
    public_key nil
    copy_of_emails  false
    github_id nil
    trello_name nil
    wiki_id nil
  end

  factory :instructor, class: Instructor do
    sequence(:name, 6) {|n| n = 6; "instructor#{n}" }
    role { Role.where(name: 'Instructor').first || association(:role_of_instructor) }
    password "password"
    password_confirmation "password"
    fullname "6, instructor"
    email "expertiza@mailinator.com"
    parent_id 1
    private_by_default  false
    mru_directory_path  nil
    email_on_review true
    email_on_submission true
    email_on_review_of_review true
    is_new_user false
    master_permission_granted 0
    handle "handle"
    digital_certificate nil
    timezonepref 'Eastern Time (US & Canada)'
    public_key nil
    copy_of_emails  false
  end

  factory :teaching_assistant, class: Ta do
    sequence(:name, 5888) {|n| n = 5888; "teaching_assistant#{n}" }
    role { Role.where(name: 'Teaching Assistant').first || association(:role_of_teaching_assistant) }
    password "password"
    password_confirmation "password"
    fullname "58888, teaching assistant"
    email "expertiza@mailinator.com"
    parent_id 1
    private_by_default  false
    mru_directory_path  nil
    email_on_review true
    email_on_submission true
    email_on_review_of_review true
    is_new_user false
    master_permission_granted 0
    handle "handle"
    digital_certificate nil
    timezonepref 'Eastern Time (US & Canada)'
    public_key nil
    copy_of_emails  false
  end

  factory :course, class: Course do
    sequence(:name) {|n| "CSC517, test#{n}" }
    instructor { Instructor.where(role_id: 1).first || association(:instructor) }
    directory_path "csc517/test"
    info "Object-Oriented Languages and Systems"
    private true
    institutions_id nil
  end

  factory :assignment, class: Assignment do
    sequence(:name, 2) {|n| n = 2; "final#{n}" }
    directory_path "final_test"
    submitter_count 0
    course { Course.first || association(:course) }
    instructor { Instructor.first || association(:instructor) }
    private false
    num_reviews 1
    num_review_of_reviews 1
    num_review_of_reviewers 1
    reviews_visible_to_all false
    num_reviewers 1
    spec_location "https://expertiza.ncsu.edu/"
    max_team_size 3
    staggered_deadline false
    allow_suggestions false
    review_assignment_strategy "Auto-Selected"
    max_reviews_per_submission 2
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
    num_reviews_required 3
    num_metareviews_required 3
    num_reviews_allowed 3
    num_metareviews_allowed 3
    is_calibrated false
  end

  factory :assignment_team, class: AssignmentTeam do
    sequence(:name) {|n| "team#{n}" }
    assignment { Assignment.first || association(:assignment) }
    type 'AssignmentTeam'
    comments_for_advertisement nil
    advertise_for_partner nil
    submitted_hyperlinks "---
- https://www.expertiza.ncsu.edu"
    directory_num 0
  end

  factory :team_user, class: TeamsUser do
    team { AssignmentTeam.first || association(:assignment_team) }
    user { User.where(role_id: 2).first || association(:student) }
  end

  factory :invitation, class: Invitation do
    reply_status 'W'
  end

  factory :course_team, class: CourseTeam do
    sequence(:name) {|n| "team#{n}" }
    course { Course.first || association(:course) }
    type 'CourseTeam'
    comments_for_advertisement nil
    advertise_for_partner nil
    submitted_hyperlinks "---
- https://www.expertiza.ncsu.edu"
    directory_num 0
  end

  factory :topic, class: SignUpTopic do
    topic_name "Hello world!"
    assignment { Assignment.first || association(:assignment) }
    max_choosers 1
    category nil
    topic_identifier "1"
    micropayment 0
    private_to nil
  end

  factory :signed_up_team, class: SignedUpTeam do
    topic { SignUpTopic.first || association(:topic) }
    team_id 1
    is_waitlisted false
    preference_priority_number nil
  end

  factory :participant, class: AssignmentParticipant do
    can_submit true
    can_review true
    assignment { Assignment.first || association(:assignment) }
    association :user, factory: :student
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

  factory :course_participant, class: CourseParticipant do
    can_submit true
    can_review true
    course { Course.first || association(:course) }
    association :user, factory: :student
    submitted_at nil
    permission_granted nil
    penalty_accumulated 0
    grade nil
    type "CourseParticipant"
    handle "handle"
    time_stamp nil
    digital_signature nil
    duty nil
    can_take_quiz true
  end

  factory :review_grade, class: ReviewGrade do
    participant { Participant.first || association(:participant) }
    grade_for_reviewer 100
    comment_for_reviewer 'Good job!'
    review_graded_at '2011-11-11 11:11:11'
    reviewer_id 1
  end

  factory :assignment_due_date, class: AssignmentDueDate do
    due_at DateTime.now.in_time_zone + 1.day
    deadline_type { DeadlineType.first || association(:deadline_type) }
    assignment { Assignment.first || association(:assignment) }
    submission_allowed_id 3
    review_allowed_id 3
    review_of_review_allowed_id 3
    round 1
    flag false
    threshold 1
    delayed_job_id nil
    deadline_name nil
    description_url nil
    quiz_allowed_id 3
    teammate_review_allowed_id 3
    type 'AssignmentDueDate'
  end

  factory :topic_due_date, class: TopicDueDate do
    due_at DateTime.now.in_time_zone + 1.day
    deadline_type { DeadlineType.first || association(:deadline_type) }
    topic { SignUpTopic.first || association(:topic) }
    submission_allowed_id 3
    review_allowed_id 3
    review_of_review_allowed_id 3
    round 1
    flag false
    threshold 1
    delayed_job_id nil
    deadline_name nil
    description_url nil
    quiz_allowed_id 3
    teammate_review_allowed_id 3
    type 'TopicDueDate'
  end

  factory :deadline_type, class: DeadlineType do
    name  "submission"
  end

  factory :deadline_right, class: DeadlineRight do
    name  "No"
  end

  factory :assignment_node, class: AssignmentNode do
    assignment { Assignment.first || association(:assignment) }
    node_object_id 1
    type "AssignmentNode"
  end

  factory :course_node, class: CourseNode do
    course { Course.first || association(:course) }
    node_object_id 1
    type "CourseNode"
  end

  factory :questionnaire, class: ReviewQuestionnaire do
    name 'Test questionnaire'
    instructor { Instructor.where(role_id: 1).first || association(:instructor) }
    private 0
    min_question_score 0
    max_question_score 5
    type 'ReviewQuestionnaire'
    display_type 'Review'
    instruction_loc nil
  end

  factory :question, class: Criterion do
    txt 'Test question:'
    weight 1
    questionnaire { Questionnaire.first || association(:questionnaire) }
    seq 1.00
    type 'Criterion'
    size "70,1"
    alternatives nil
    break_before 1
    max_label nil
    min_label nil
  end

  factory :question_advice, class: QuestionAdvice do
    question { Question.first || association(:question) }
    score 5
    advice 'LGTM'
  end

  factory :assignment_questionnaire, class: AssignmentQuestionnaire do
    assignment { Assignment.first || association(:assignment) }
    questionnaire { ReviewQuestionnaire.first || association(:questionnaire) }
    user_id 1
    questionnaire_weight 100
    used_in_round nil
    dropdown 1
  end

  factory :review_response_map, class: ReviewResponseMap do
    assignment { Assignment.first || association(:assignment) }
    reviewee { AssignmentTeam.first || association(:assignment_team) }
    reviewer_id 1
    type 'ReviewResponseMap'
    calibrate_to 0
  end

  factory :meta_review_response_map, class: MetareviewResponseMap do
    review_mapping { ReviewResponseMap.first || association(:review_response_map) }
    reviewee { AssignmentParticipant.first || association(:participant) }
    reviewer_id 1
    type 'MetareviewResponseMap'
    calibrate_to 0
  end

  factory :response, class: Response do
    response_map { ReviewResponseMap.first || association(:review_response_map) }
    additional_comment nil
    version_num nil
    round 1
    is_submitted false
  end

  factory :submission_record, class: SubmissionRecord do
    team_id 666
    operation 'create'
    user 'student1234'
    content 'www.wolfware.edu'
    created_at Time.now
  end

  factory :metric_data_point_type, class: MetricDataPointType do
    name "commit_id"
    source :github
    value_type "string"
    description "Commit Id"
    dimension "label"
    id 1
  end

  factory :metric, class: Metric do
    team { AssignmentTeam.first || association(:assignment_team) }
    assignment { Assignment.first || association(:assignment) }
    source :github
    remote_id "url"
    uri "newmetric"
    id 1
  end

  factory :metric_data_point, class: MetricDataPoint do
    metric { Metric.first || association(:metric) }
    metric_data_point_type { MetricDataPointType.first || association(:metric_data_point_type) }
    value "1"
  end
end
