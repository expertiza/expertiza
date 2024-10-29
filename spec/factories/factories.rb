FactoryBot.define do
  factory :institution, class: Institution do
    name 'North Carolina State University'
  end

  factory :markup_style, class: MarkupStyle do
    name 'Duy Test'
  end 

  factory :lock, class: Lock do
    lockable_id 123
    lockable_type 'Duy lockable test'
    user_id 1234
  end 

  factory :review_bid, class: ReviewBid do
    priority 2
    signuptopic_id 123
  end

  factory :role_of_administrator, class: Role do
    name 'Administrator'
    parent_id nil
    description ''
  end

  factory :role_of_superadministrator, class: Role do
    name 'Super-Administrator'
    parent_id nil
    description ''
  end

  factory :role_of_student, class: Role do
    name 'Student'
    parent_id  nil
    description ''
  end

  factory :role_of_instructor, class: Role do
    name 'Instructor'
    parent_id nil
    description ''
  end

  factory :role_of_teaching_assistant, class: Role do
    name 'Teaching Assistant'
    parent_id nil
    description ''
  end

  factory :admin, class: User do
    sequence(:username) { |n| "admin#{n}" }
    role { Role.where(name: 'Administrator').first || association(:role_of_administrator) }
    password 'password'
    password_confirmation 'password'
    sequence(:name) { |n| "#{n}, administrator" }
    email 'expertiza@mailinator.com'
    parent_id 1
    private_by_default  false
    mru_directory_path  nil
    email_on_review true
    email_on_submission true
    email_on_review_of_review true
    is_new_user false
    master_permission_granted 0
    handle 'handle'
    digital_certificate nil
    timezonepref nil
    public_key nil
    copy_of_emails  false
  end

  factory :superadmin, class: User do
    sequence(:username) { |n| "superadmin#{n}" }
    role { Role.where(name: 'Super-Administrator').first || association(:role_of_superadministrator) }
    password 'password'
    password_confirmation 'password'
    sequence(:name) { |n| "#{n}, superadministrator" }
    email 'expertiza@mailinator.com'
    parent_id 1
    private_by_default  false
    mru_directory_path  nil
    email_on_review true
    email_on_submission true
    email_on_review_of_review true
    is_new_user false
    master_permission_granted 0
    handle 'handle'
    digital_certificate nil
    timezonepref nil
    public_key nil
    copy_of_emails false
  end

  factory :loggermessage, class: LoggerMessage do
    generator nil
    unity_id nil
    message 'Success'
    oip nil
    req_id nil
  end

  factory :mentor, class: AssignmentParticipant do
    sequence(:username) { |n| n = n % 3; "mentor206#{n + 4}" }
    can_submit true
    can_review true
    assignment { Assignment.first || association(:assignment) }
    association :user, factory: :student
    submitted_at nil
    permission_granted nil
    penalty_accumulated 0
    grade nil
    type 'AssignmentParticipant'
    handle 'handle'
    time_stamp nil
    digital_signature nil
    can_mentor true
    can_take_quiz true
  end


  factory :student, class: User do
    # Zhewei: In order to keep students the same names (2065, 2066, 2064) before each example.
    sequence(:username) { |n| n = n % 3; "student206#{n + 4}" }
    role { Role.where(name: 'Student').first || association(:role_of_student) }
    password 'password'
    password_confirmation 'password'
    sequence(:name) { |n| n = n % 3; "206#{n + 4}, student" }
    email 'expertiza@mailinator.com'
    parent_id 1
    private_by_default  false
    mru_directory_path  nil
    email_on_review true
    email_on_submission true
    email_on_review_of_review true
    is_new_user false
    master_permission_granted 0
    handle 'handle'
    digital_certificate nil
    timezonepref 'Eastern Time (US & Canada)'
    public_key nil
    copy_of_emails false
  end

  factory :instructor, class: Instructor do
    username 'instructor6'
    role { Role.where(name: 'Instructor').first || association(:role_of_instructor) }
    password 'password'
    password_confirmation 'password'
    name '6, instructor'
    email 'expertiza@mailinator.com'
    parent_id 1
    private_by_default  false
    mru_directory_path  nil
    email_on_review true
    email_on_submission true
    email_on_review_of_review true
    is_new_user false
    master_permission_granted 0
    handle 'handle'
    digital_certificate nil
    timezonepref 'Eastern Time (US & Canada)'
    public_key nil
    copy_of_emails false
  end

  factory :teaching_assistant, class: Ta do
    username 'teaching_assistant5888'
    role { Role.where(name: 'Teaching Assistant').first || association(:role_of_teaching_assistant) }
    password 'password'
    password_confirmation 'password'
    name '5888, teaching assistant'
    email 'expertiza@mailinator.com'
    parent_id 1
    private_by_default  false
    mru_directory_path  nil
    email_on_review true
    email_on_submission true
    email_on_review_of_review true
    is_new_user false
    master_permission_granted 0
    handle 'handle'
    digital_certificate nil
    timezonepref 'Eastern Time (US & Canada)'
    public_key nil
    copy_of_emails  false
  end

  factory :course, class: Course do
    sequence(:name) { |n| "CSC517, test#{n}" }
    instructor { Instructor.first || association(:instructor) }
    directory_path 'csc517/test'
    info 'Object-Oriented Languages and Systems'
    private true
    institutions_id nil
  end

  factory :assignment, class: Assignment do
    # Help multiple factory-created assignments get unique names
    # Let the first created assignment have the name 'final2' to avoid breaking some fragile existing tests
    name { (Assignment.last ? ('assignment' + (Assignment.last.id + 1).to_s) : 'final2').to_s }
    directory_path 'final_test'
    submitter_count 0
    course { Course.first || association(:course) }
    instructor { Instructor.first || association(:instructor) }
    private false
    num_reviews 1
    num_review_of_reviews 1
    num_review_of_reviewers 1
    reviews_visible_to_all false
    num_reviewers 1
    spec_location 'https://expertiza.ncsu.edu/'
    max_team_size 3
    staggered_deadline false
    allow_suggestions false
    review_assignment_strategy 'Auto-Selected'
    max_reviews_per_submission 2
    review_topic_threshold 0
    copy_flag false
    rounds_of_reviews 2
    vary_by_round? false
    vary_by_topic? false
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
    has_badge false
    allow_selecting_additional_reviews_after_1st_round false
    auto_assign_mentor false
  end

  factory :late_policy, class: LatePolicy do
    # Help multiple factory-created assignments get unique names
    # Let the first created assignment have the name 'final2' to avoid breaking some fragile existing tests
    policy_name 'Dummy Name'
    instructor_id 1
    max_penalty 5
    penalty_per_unit 1
    penalty_unit 1
    assignments { [Assignment.first || association(:assignment)] }
  end

  factory :calculated_penalty, class: CalculatedPenalty do
    participant_id 1
    deadline_type_id 1
  end

  factory :assignment_team, class: AssignmentTeam do
    sequence(:name) { |n| "team#{n}" }
    assignment { Assignment.first || association(:assignment) }
    type 'AssignmentTeam'
    comments_for_advertisement nil
    advertise_for_partner nil
    submitted_hyperlinks '---
- https://www.expertiza.ncsu.edu'
    directory_num 0
  end

  factory :course_team, class: CourseTeam do
    sequence(:name) { |n| "team#{n}" }
    course { Course.first || association(:course) }
    type 'CourseTeam'
    comments_for_advertisement nil
    advertise_for_partner nil
    submitted_hyperlinks '---
- https://www.expertiza.ncsu.edu'
    directory_num 0
  end

  factory :team_user, class: TeamsUser do
    team { AssignmentTeam.first || association(:assignment_team) }
    # Beware: it is fragile to assume that role_id of student is 2 (or any other unchanging value)
    user { User.where(role_id: 2).first || association(:student) }
  end

  factory :team, class: Team do
    id 1
    name 'testteam'
    parent_id 1
  end

  factory :invitation, class: Invitation do
    reply_status 'W'
  end
  factory :join_team_request, class: JoinTeamRequest do
    id 1
    participant_id 5
    comments 'some comments'
    team_id 1
    status 'P'
    created_at '2020-03-24 12:10:20'
    updated_at '2020-03-24 12:10:20'
  end
  factory :topic, class: SignUpTopic do
    topic_name 'Hello world!'
    assignment { Assignment.first || association(:assignment) }
    max_choosers 1
    category nil
    topic_identifier '1'
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
    type 'AssignmentParticipant'
    handle 'handle'
    time_stamp nil
    digital_signature nil
    can_mentor false
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
    type 'CourseParticipant'
    handle 'handle'
    time_stamp nil
    digital_signature nil
    can_mentor false
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
    submission_allowed_id { DeadlineRight.first.nil? ? association(:deadline_right).id : DeadlineRight.first.id }
    review_allowed_id { DeadlineRight.first.nil? ? association(:deadline_right).id : DeadlineRight.first.id }
    review_of_review_allowed_id { DeadlineRight.first.nil? ? association(:deadline_right).id : DeadlineRight.first.id }
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
    name  'submission'
  end

  factory :deadline_right, class: DeadlineRight do
    name  'OK'
  end

  factory :assignment_node, class: AssignmentNode do
    assignment { Assignment.first || association(:assignment) }
    node_object_id 1
    type 'AssignmentNode'
  end

  factory :questionnaire_type_node, class: QuestionnaireTypeNode do
    node_object_id 1
    type 'QuestionnaireTypeNode'
  end

  factory :assignment_team_node, class: TeamNode do
    node_object { AssignmentTeam.first || association(:assignment_team) }
    node_object_id 1
    type 'TeamNode'
  end

  factory :course_node, class: CourseNode do
    course { Course.first || association(:course) }
    node_object_id 1
    type 'CourseNode'
  end

  factory :questionnaire, class: ReviewQuestionnaire do
    name 'Test questionnaire'
    # Beware: it is fragile to assume that role_id of instructor is 1 (or any other unchanging value)
    instructor { Instructor.first || association(:instructor) }
    private 0
    min_question_score 0
    max_question_score 5
    type 'ReviewQuestionnaire'
    display_type 'Review'
    instruction_loc nil
  end

  factory :teammate_questionnaire, class: TeammateReviewQuestionnaire do
    name 'Test questionnaire'
    # Beware: it is fragile to assume that role_id of instructor is 1 (or any other unchanging value)
    instructor { Instructor.first || association(:instructor) }
    private 0
    min_question_score 0
    max_question_score 5
    type 'TeammateReviewQuestionnaire'
    display_type 'Review'
    instruction_loc nil
  end

  factory :questionnaire_node, class: QuestionnaireNode do
    parent_id 0
    node_object_id 0
    type 'QuestionnaireNode'
  end

  factory :question, class: Criterion do
    txt 'Test question:'
    weight 1
    questionnaire { Questionnaire.first || association(:questionnaire) }
    seq 1.00
    type 'Criterion'
    size '70,1'
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
    topic_id nil
    dropdown 1
  end

  factory :assignment_teammate_questionnaire, class: AssignmentQuestionnaire do
    assignment { Assignment.first || association(:assignment) }
    questionnaire { TeammateReviewQuestionnaire.first || association(:teammate_questionnaire) }
    user_id 1
    questionnaire_weight 100
    used_in_round nil
    topic_id nil
    dropdown 1
  end

  factory :bookmark_questionnaire, class: BookmarkRatingQuestionnaire do
    name 'BookmarkRatingQuestionnaire'
    assignments { [Assignment.first || association(:assignment)] }
    min_question_score 0
    max_question_score 5
    type 'BookmarkRatingQuestionnaire'
  end

  factory :review_response_map, class: ReviewResponseMap do
    assignment { Assignment.first || association(:assignment) }
    reviewer { AssignmentParticipant.first || association(:participant) }
    reviewee { AssignmentTeam.first || association(:assignment_team) }
    type 'ReviewResponseMap'
    calibrate_to 0
  end

  factory :teammate_review_response_map, class: TeammateReviewResponseMap do
    assignment { Assignment.first || association(:assignment) }
    reviewer { AssignmentParticipant.first || association(:participant) }
    reviewee { AssignmentParticipant.first || association(:participant) }
    type 'TeammateReviewResponseMap'
    calibrate_to 0
  end

  factory :feedback_response_map, class: FeedbackResponseMap do
    type 'FeedbackResponseMap'
    calibrate_to 0
  end

  factory :self_review_response_map, class: SelfReviewResponseMap do
    assignment { Assignment.first || association(:assignment) }
    reviewer { AssignmentParticipant.first || association(:participant) }
    reviewee { AssignmentTeam.first || association(:assignment_team) }
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

  factory :bookmark_review_response_map, class: BookmarkRatingResponseMap do
    assignment { Assignment.first || association(:assignment) }
    reviewer { AssignmentParticipant.first || association(:participant) }
    reviewee { Bookmark.first || association(:assignment_team) }
    type 'BookmarkRatingResponseMap'
    calibrate_to 0
  end

  factory :response, class: Response do
    response_map { ReviewResponseMap.first || association(:review_response_map) }
    additional_comment nil
    version_num nil
    round 1
    is_submitted false
    visibility 'private'
  end

  factory :submission_record, class: SubmissionRecord do
    assignment_id 1
    team_id 666
    operation 'create'
    user 'student1234'
    content 'www.wolfware.edu'
    created_at Time.now
  end

  factory :requested_user, class: AccountRequest do
    username 'requester1'
    role_id 2
    name 'requester, requester'
    institution_id 1
    email 'requester1@test.com'
    status 'Under Review'
    self_introduction 'no one'
  end

  factory :badge, class: Badge do
    name 'Good Reviewer'
    description 'description'
    image_name 'good-reviewer.png'
  end

  factory :assignment_badge, class: AssignmentBadge do
    badge { Badge.first || association(:badge) }
    assignment { Assignment.first || association(:assignment) }
    threshold 95
  end

  factory :awarded_badge, class: AwardedBadge do
    badge { Badge.first || association(:badge) }
    participant { AssignmentParticipant.first || association(:participant) }
  end

  factory :menu_item, class: MenuItem do
    parent_id nil
    name 'home'
    label 'Home'
    seq 1
    controller_action_id nil
    content_page_id nil
  end

  factory :bookmark, class: Bookmark do
    id 1
    url 'example.com'
    title 'Test Bookmark'
    description 'Test description'
    user_id '1234'
    topic_id '1'
    created_at '2020-03-24 12:10:20'
    updated_at '2020-03-24 12:10:20'
  end

  factory :site_controller, class: SiteController do
    id 1
    name 'fake_site'
  end

  factory :duty, class: Duty do
    id 1
    name 'Scrum Master'
    max_members_for_duty 1
    assignment_id 1
  end

  factory :version, class: Version do
    item_type 'Node'
    item_id 1
    event 'create'
    whodunnit nil
    object nil
    created_at '2015-06-11 15:11:51'
  end

  factory :test_user, class: User do
    sequence(:username) { |n| "username#{n}" }
    name 'full name'
    sequence(:email) { |n| "user#{n}@mailinator.com" }
  end

  factory :survey_deployment, class: SurveyDeployment do
    type 'AssignmentSurveyDeployment'
  end

  factory :multiple_choice_checkbox, class: MultipleChoiceCheckbox do
    txt 'Test question:'
    weight 1
    questionnaire { Questionnaire.first || association(:questionnaire) }
    seq 1.00
    type 'MultipleChoiceCheckbox'
    size '70,1'
  end

  factory :true_false, class: TrueFalse do
    txt 'Test question:'
    weight 1
    questionnaire { Questionnaire.first || association(:questionnaire) }
    seq 1.00
    type 'TrueFalse'
    size '70,1'
  end

  factory :scored_question, class: ScoredQuestion do
    txt 'Test question:'
    weight 1
    questionnaire { Questionnaire.first || association(:questionnaire) }
    seq 1.00
    type 'ScoredQuestion'
    size '70,1'
  end

  factory :questionnaire_header, class: QuestionnaireHeader do
    txt 'Test question:'
    weight 1
    questionnaire { Questionnaire.first || association(:questionnaire) }
    seq 1.00
    type 'QuestionnaireHeader'
    size '70,1'
  end

  factory :section_header, class: SectionHeader do
    txt 'Test question:'
    weight 1
    questionnaire { Questionnaire.first || association(:questionnaire) }
    seq 1.00
    type 'SectionHeader'
    size '70,1'
  end

  factory :dropdown, class: Dropdown do
    txt 'Test question:'
    weight 1
    questionnaire { Questionnaire.first || association(:questionnaire) }
    seq 1.00
    type 'TrueFalse'
    size '70,1'
  end

  factory :text_area, class: TextArea do
    txt 'Test question:'
    weight 1
    questionnaire { Questionnaire.first || association(:questionnaire) }
    seq 1.00
    type 'TextArea'
    size '70,1'
  end

  factory :content_page, class: ContentPage do
    title 'Expertiza Home'
    name 'home'
  end

  factory :suggestion, class: Suggestion do
    id 1
    assignment_id 1
    title 'oss topic'
    description 'add oss topic'
    status 'Initiated'
    unityID 'student2065'
    signup_preference 'Y'
  end

  factory :suggestion_comment, class: SuggestionComment do
    id 1
    comments 'this is a suggestion_comment'
    commenter 'oss topic'
    vote 'Y'
    suggestion_id 1
  end

  factory :answer_tag, class: AnswerTag do
    answer { Answer.first || association(:answer) }
    tag_prompt_deployment { TagPromptDeployment.first || association(:tag_prompt_deployment) }
    user { User.first || association(:user) }
    value '0'
  end

  factory :tag_prompt, class: TagPrompt do
    prompt 'Prompt'
    desc 'Description'
    control_type 'Slider'
  end

  factory :tag_prompt_deployment, class: TagPromptDeployment do
    tag_prompt { TagPrompt.first || association(:tag_prompt) }
    assignment { Assignment.first || association(:assignment) }
    questionnaire { Questionnaire.first || association(:questionnaire) }
    question_type 'Criterion'
    answer_length_threshold 6
  end

  factory :ta_mapping, class: TaMapping do
    id 1
    ta_id 1
    course_id 1
  end
end
