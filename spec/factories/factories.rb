FactoryGirl.define do

  factory :role_of_student ,class: Role do
    name "Student"
    parent_id  nil 
    description  "" 
    cache YAML::load('---
:credentials: !ruby/object:Credentials
  actions:
    content_pages:
      view_default: true
      view: true
      list: false
    roles:
      list: false
    permissions:
      list: false
    auth:
      login: true
      logout: true
      login_failed: true
    menu_items:
      link: true
      list: false
    site_controllers:
      list: false
    controller_actions:
      list: false
    system_settings:
      list: false
    users:
      list: false
      keys: true
    admin:
      list_instructors: false
      list_administrators: false
      list_super_administrators: false
    course:
      list_folders: false
      add_ta: false
      destroy_course: false
      edit_course: false
      new_course: false
      new_folder: false
      remove_ta: false
      update_course: false
      view_teaching_assistants: false
      create_course: false
      list: false
    suggestion:
      create: true
      new: true
    questionnaire:
      list: false
      create_questionnaire: false
      edit_questionnaire: false
      copy_questionnaire: false
      save_questionnaire: false
      new_quiz: true
      create_quiz_questionnaire: true
      update_quiz: true
      edit_quiz: true
      view_quiz: true
    participants:
      add_student: false
      edit_team_members: false
      list_students: false
      list_courses: false
      list_assignments: false
      change_handle: true
    assignment:
      list: false
    institution:
      list: false
    student_task:
      list: true
    profile:
      edit: true
    survey_response:
      create: true
      submit: true
    team:
      list: false
      list_assignments: false
    teams_users:
      list: false
    course_evaluation:
      list: true
    survey_deployment:
      list: false
    statistics:
      list_surveys: false
    impersonate:
      start: false
      impersonate: true
    review_mapping:
      list: false
      assign_reviewer_dynamically: true
      release_reservation: true
      show_available_submissions: true
      assign_metareviewer_dynamically: true
      add_self_reviewer: true
      assign_quiz_dynamically: true
    tree_display:
      list: false
      drill: false
      goto_questionnaires: false
      goto_author_feedbacks: false
      goto_review_rubrics: false
      goto_global_survey: false
      goto_surveys: false
      goto_course_evaluations: false
      goto_courses: false
      goto_assignments: false
      goto_teammate_reviews: false
      goto_metareview_rubrics: false
      goto_teammatereview_rubrics: false
    grades:
      view_my_scores: true
    sign_up_sheet:
      signup_topics: true
      signup: true
      delete_signup: true
      team_details: true
    leaderboard:
      index: true
    review_files:
      show_code_file: true
      show_code_file_diff: true
      show_all_submitted_files: true
      submit_comment: true
      submit_review_file: true
    popup:
      automated_metareview_details_popup: true
    advice:
      edit_advice: false
      save_advice: false
    response:
      delete: false
    analytic:
      assignment_list: false
      course_list: false
      get_graph_data_bundle: false
      graph_data_type_list: false
      index: false
      init: false
      render_sample: false
      team_list: false
    advertise_for_partner:
      remove: true
    versions:
      revert: true
  controllers:
    content_pages: false
    controller_actions: false
    auth: false
    markup_styles: false
    menu_items: false
    permissions: false
    roles: false
    site_controllers: false
    system_settings: false
    users: true
    roles_permissions: false
    admin: false
    course: false
    assignment: false
    questionnaire: false
    participants: false
    reports: true
    institution: false
    student_task: true
    profile: true
    survey_response: true
    team: false
    teams_users: false
    import_file: false
    course_evaluation: true
    participant_choices: false
    survey_deployment: false
    statistics: false
    impersonate: false
    review_mapping: false
    grades: false
    tree_display: false
    student_team: true
    invitation: true
    survey: false
    password_retrieval: true
    submitted_content: true
    eula: true
    student_review: true
    publishing: true
    export_file: false
    response: true
    popup: false
    sign_up_sheet: false
    suggestion: false
    leaderboard: true
    delete_object: false
    assessment360: false
    review_files: true
    advertise_for_partners: true
    join_team_requests: true
    advertise_for_partner: true
    automated_metareviews: true
    advice: false
    analytic: false
    versions: true
    student_quiz: true
  pages:
    home: true
    expired: true
    notfound: true
    denied: true
    contact_us: true
    site_admin: false
    adminpage: false
    credits: true
    wiki: true
  permission_ids:
  - 8
  - 4
  - 3
  role_id: 1
  role_ids:
  - 1
  updated_at: 2015-06-11 15:23:43.000000000 Z
:menu: !ruby/object:Menu
  by_id:
    1: &1 !ruby/object:Menu::Node
      content_page_id: 1
      controller_action_id:
      id: 1
      label: Home
      name: home
      parent:
      parent_id:
      site_controller_id:
      url: "/home"
      children:
      - 50
    26: &2 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 33
      id: 26
      label: Assignments
      name: student_task
      parent:
      parent_id:
      site_controller_id: 23
      url: "/student_task/list"
    30: &3 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 42
      id: 30
      label: Course Evaluation
      name: Course Evaluation
      parent:
      parent_id:
      site_controller_id: 31
      url: "/course_evaluation/list"
    27: &4 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 36
      id: 27
      label: Profile
      name: profile
      parent:
      parent_id:
      site_controller_id: 26
      url: "/profile/edit"
    2: &5 !ruby/object:Menu::Node
      content_page_id: 6
      controller_action_id:
      id: 2
      label: Contact Us
      name: contact_us
      parent:
      parent_id:
      site_controller_id:
      url: "/contact_us"
      children:
      - 14
    50: &6 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 78
      id: 50
      label: Leaderboard
      name: leaderboard
      parent:
      parent_id: 1
      site_controller_id: 54
      url: "/leaderboard/index"
    14: &7 !ruby/object:Menu::Node
      content_page_id: 10
      controller_action_id:
      id: 14
      label: Credits &amp; Licence
      name: credits
      parent:
      parent_id: 2
      site_controller_id:
      url: "/credits"
  by_name:
    home: *1
    student_task: *2
    Course Evaluation: *3
    profile: *4
    contact_us: *5
    leaderboard: *6
    credits: *7
  crumbs:
  - 1
  root: &8 !ruby/object:Menu::Node
    parent:
    children:
    - 1
    - 26
    - 30
    - 27
    - 2
  selected:
    1: *1
  vector:
  - *8
  - *1
')     
  end

  factory :role_of_instructor ,class: Role do
    name "Instructor"
    parent_id  nil 
    description  "" 
    cache YAML::load('---
:credentials: !ruby/object:Credentials
  actions:
    content_pages:
      view_default: true
      view: true
      list: false
    roles:
      list: false
    permissions:
      list: false
    auth:
      login: true
      logout: true
      login_failed: true
    menu_items:
      link: true
      list: false
    site_controllers:
      list: false
    controller_actions:
      list: false
    system_settings:
      list: false
    users:
      list: true
      keys: true
    admin:
      list_instructors: false
      list_administrators: false
      list_super_administrators: false
    course:
      list_folders: true
      add_ta: true
      destroy_course: true
      edit_course: true
      new_course: true
      new_folder: true
      remove_ta: true
      update_course: true
      view_teaching_assistants: true
      create_course: true
      list: true
    suggestion:
      create: true
      new: true
    questionnaire:
      list: true
      create_questionnaire: true
      edit_questionnaire: true
      copy_questionnaire: true
      save_questionnaire: true
      new_quiz: true
      create_quiz_questionnaire: true
      update_quiz: true
      edit_quiz: true
      view_quiz: true
    participants:
      add_student: true
      edit_team_members: true
      list_students: true
      list_courses: true
      list_assignments: true
      change_handle: true
    assignment:
      list: true
    institution:
      list: false
    student_task:
      list: true
    profile:
      edit: true
    survey_response:
      create: true
      submit: true
    team:
      list: true
      list_assignments: true
    teams_users:
      list: true
    course_evaluation:
      list: true
    survey_deployment:
      list: true
    statistics:
      list_surveys: true
    impersonate:
      start: true
      impersonate: true
    review_mapping:
      list: true
      assign_reviewer_dynamically: true
      release_reservation: true
      show_available_submissions: true
      assign_metareviewer_dynamically: true
      add_self_reviewer: true
      assign_quiz_dynamically: true
    tree_display:
      list: true
      drill: true
      goto_questionnaires: true
      goto_author_feedbacks: true
      goto_review_rubrics: true
      goto_global_survey: true
      goto_surveys: true
      goto_course_evaluations: true
      goto_courses: true
      goto_assignments: true
      goto_teammate_reviews: true
      goto_metareview_rubrics: true
      goto_teammatereview_rubrics: true
    grades:
      view_my_scores: true
    sign_up_sheet:
      signup_topics: true
      signup: true
      delete_signup: true
      team_details: true
    leaderboard:
      index: true
    review_files:
      show_code_file: true
      show_code_file_diff: true
      show_all_submitted_files: true
      submit_comment: true
      submit_review_file: true
    popup:
      automated_metareview_details_popup: true
    advice:
      edit_advice: true
      save_advice: true
    response:
      delete: true
    analytic:
      assignment_list: true
      course_list: true
      get_graph_data_bundle: true
      graph_data_type_list: true
      index: true
      init: true
      render_sample: true
      team_list: true
    advertise_for_partner:
      remove: true
    versions:
      revert: true
  controllers:
    content_pages: false
    controller_actions: false
    auth: false
    markup_styles: false
    menu_items: false
    permissions: false
    roles: false
    site_controllers: false
    system_settings: false
    users: true
    roles_permissions: false
    admin: false
    course: true
    assignment: true
    questionnaire: true
    participants: true
    reports: true
    institution: false
    student_task: true
    profile: true
    survey_response: true
    team: true
    teams_users: true
    import_file: true
    course_evaluation: true
    participant_choices: true
    survey_deployment: true
    statistics: true
    impersonate: true
    review_mapping: true
    grades: true
    tree_display: true
    student_team: true
    invitation: true
    survey: true
    password_retrieval: true
    submitted_content: true
    eula: true
    student_review: true
    publishing: true
    export_file: true
    response: true
    popup: true
    sign_up_sheet: true
    suggestion: true
    leaderboard: true
    delete_object: true
    assessment360: true
    review_files: true
    advertise_for_partners: true
    join_team_requests: true
    advertise_for_partner: true
    automated_metareviews: true
    advice: true
    analytic: true
    versions: true
    student_quiz: true
  pages:
    home: true
    expired: true
    notfound: true
    denied: true
    contact_us: true
    site_admin: false
    adminpage: true
    credits: true
    wiki: true
  permission_ids:
  - 7
  - 10
  - 8
  - 4
  - 3
  role_id: 2
  role_ids:
  - 2
  - 6
  - 1
  updated_at: 2015-06-11 15:23:44.000000000 Z
:menu: !ruby/object:Menu
  by_id:
    1: &1 !ruby/object:Menu::Node
      content_page_id: 1
      controller_action_id:
      id: 1
      label: Home
      name: home
      parent:
      parent_id:
      site_controller_id:
      url: "/home"
      children:
      - 50
    37: &2 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 59
      id: 37
      label: Manage...
      name: manage instructor content
      parent:
      parent_id:
      site_controller_id: 38
      url: "/tree_display/drill"
      children:
      - 13
      - 38
      - 44
      - 45
      - 33
    35: &3 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 43
      id: 35
      label: Survey Deployments
      name: Survey Deployments
      parent:
      parent_id:
      site_controller_id: 33
      url: "/survey_deployment/list"
      children:
      - 36
    26: &4 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 33
      id: 26
      label: Assignments
      name: student_task
      parent:
      parent_id:
      site_controller_id: 23
      url: "/student_task/list"
    30: &5 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 42
      id: 30
      label: Course Evaluation
      name: Course Evaluation
      parent:
      parent_id:
      site_controller_id: 31
      url: "/course_evaluation/list"
    27: &6 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 36
      id: 27
      label: Profile
      name: profile
      parent:
      parent_id:
      site_controller_id: 26
      url: "/profile/edit"
    2: &7 !ruby/object:Menu::Node
      content_page_id: 6
      controller_action_id:
      id: 2
      label: Contact Us
      name: contact_us
      parent:
      parent_id:
      site_controller_id:
      url: "/contact_us"
      children:
      - 14
    50: &8 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 78
      id: 50
      label: Leaderboard
      name: leaderboard
      parent:
      parent_id: 1
      site_controller_id: 54
      url: "/leaderboard/index"
    14: &9 !ruby/object:Menu::Node
      content_page_id: 10
      controller_action_id:
      id: 14
      label: Credits &amp; Licence
      name: credits
      parent:
      parent_id: 2
      site_controller_id:
      url: "/credits"
    46: &10 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 15
      id: 46
      label: Show...
      name: show
      parent:
      parent_id: 3
      site_controller_id: 10
      url: "/users/list"
    36: &11 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 44
      id: 36
      label: Statistical Test
      name: Statistical Test
      parent:
      parent_id: 35
      site_controller_id: 34
      url: "/statistics/list_surveys"
    13: &12 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 15
      id: 13
      label: Users
      name: manage/users
      parent:
      parent_id: 37
      site_controller_id: 10
      url: "/users/list"
    38: &13 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 60
      id: 38
      label: Questionnaires
      name: manage/questionnaires
      parent:
      parent_id: 37
      site_controller_id: 38
      url: "/tree_display/goto_questionnaires"
      children:
      - 39
      - 48
      - 49
      - 40
      - 41
      - 42
      - 43
    44: &14 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 66
      id: 44
      label: Courses
      name: manage/courses
      parent:
      parent_id: 37
      site_controller_id: 38
      url: "/tree_display/goto_courses"
    45: &15 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 67
      id: 45
      label: Assignments
      name: manage/assignments
      parent:
      parent_id: 37
      site_controller_id: 38
      url: "/tree_display/goto_assignments"
    33: &16 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 45
      id: 33
      label: Impersonate User
      name: impersonate
      parent:
      parent_id: 37
      site_controller_id: 35
      url: "/impersonate/start"
    39: &17 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 62
      id: 39
      label: Review rubrics
      name: manage/questionnaires/review rubrics
      parent:
      parent_id: 38
      site_controller_id: 38
      url: "/tree_display/goto_review_rubrics"
    48: &18 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 72
      id: 48
      label: Metareview rubrics
      name: manage/questionnaires/metareview rubrics
      parent:
      parent_id: 38
      site_controller_id: 38
      url: "/tree_display/goto_metareview_rubrics"
    49: &19 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 73
      id: 49
      label: Teammate review rubrics
      name: manage/questionnaires/teammate review rubrics
      parent:
      parent_id: 38
      site_controller_id: 38
      url: "/tree_display/goto_teammatereview_rubrics"
    40: &20 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 61
      id: 40
      label: Author feedbacks
      name: manage/questionnaires/author feedbacks
      parent:
      parent_id: 38
      site_controller_id: 38
      url: "/tree_display/goto_author_feedbacks"
    41: &21 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 63
      id: 41
      label: Global survey
      name: manage/questionnaires/global survey
      parent:
      parent_id: 38
      site_controller_id: 38
      url: "/tree_display/goto_global_survey"
    42: &22 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 64
      id: 42
      label: Surveys
      name: manage/questionnaires/surveys
      parent:
      parent_id: 38
      site_controller_id: 38
      url: "/tree_display/goto_surveys"
    43: &23 !ruby/object:Menu::Node
      content_page_id:
      controller_action_id: 64
      id: 43
      label: Course evaluations
      name: manage/questionnaires/course evaluations
      parent:
      parent_id: 38
      site_controller_id: 38
      url: "/tree_display/goto_surveys"
  by_name:
    home: *1
    manage instructor content: *2
    Survey Deployments: *3
    student_task: *4
    Course Evaluation: *5
    profile: *6
    contact_us: *7
    leaderboard: *8
    credits: *9
    show: *10
    Statistical Test: *11
    manage/users: *12
    manage/questionnaires: *13
    manage/courses: *14
    manage/assignments: *15
    impersonate: *16
    manage/questionnaires/review rubrics: *17
    manage/questionnaires/metareview rubrics: *18
    manage/questionnaires/teammate review rubrics: *19
    manage/questionnaires/author feedbacks: *20
    manage/questionnaires/global survey: *21
    manage/questionnaires/surveys: *22
    manage/questionnaires/course evaluations: *23
  crumbs:
  - 1
  root: &24 !ruby/object:Menu::Node
    parent:
    children:
    - 1
    - 37
    - 35
    - 26
    - 30
    - 27
    - 2
  selected:
    1: *1
  vector:
  - *24
  - *1
')
  end

  factory :student, class: User do
    # Zhewei: In order to keep students the same names (2064, 2065, 2066) before each example.
    sequence(:name) { |n| n=n%3;  "student206#{n+4}" }
    role { Role.where(name: 'Student').first || association(:role_of_student) } 
    password "password"
    password_confirmation "password"
    sequence(:fullname) { |n| n=n%3; "206#{n+4}, student" }
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
    timezonepref 'Eastern Time (US & Canada)'
    public_key nil
    copy_of_emails  false
  end
  
  factory :instructor, class: User do
    sequence(:name, 6) { |n| n=6; "instructor#{n}" }
    role { Role.where(name: 'Instructor').first || association(:role_of_instructor) } 
    password "password"
    password_confirmation "password"
    fullname "6, instructor"
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
    timezonepref 'Eastern Time (US & Canada)'
    public_key nil
    copy_of_emails  false
  end

  factory :course ,class:Course do
    sequence(:name) { |n| "CSC517, test#{n}" }
    instructor {User.where(role_id: 1).first || association(:instructor)} 
    directory_path "csc517/test"
    info "Object-Oriented Languages and Systems"
    private true
    institutions_id nil
  end

  factory :assignment ,class:Assignment do
    sequence(:name, 2) { |n| n=2; "final#{n}" }
    directory_path "final_test" 
    submitter_count 0 
    course { Course.first || association(:course)} 
    instructor { User.first || association(:instructor)} 
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
  end

  factory :assignment_team, class:AssignmentTeam do
    sequence(:name){|n| "team#{n}"}
    assignment { Assignment.first || association(:assignment)} 
    type 'AssignmentTeam'                     
    comments_for_advertisement nil
    advertise_for_partner nil
    submitted_hyperlinks "---
- https://www.expertiza.ncsu.edu" 
    directory_num 0
  end

  factory :team_user, class:TeamsUser do
    team {AssignmentTeam.first || association(:assignment_team)}
    user {User.where(role_id: 2).first || association(:student)} 
  end

  factory :topic, class:SignUpTopic do
    topic_name "Hello world!"
    assignment { Assignment.first || association(:assignment)} 
    max_choosers 1
    category nil
    topic_identifier "1"
    micropayment 0 
    private_to nil
  end   

  factory :signed_up_team, class:SignedUpTeam do
    topic {SignUpTopic.first || association(:topic)}                  
    team_id 1       
    is_waitlisted 0            
    preference_priority_number nil
  end

  factory :participant, class:Participant do
    can_submit true
    can_review true
    assignment { Assignment.first || association(:assignment)} 
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

  factory :due_date ,class:DueDate do
    due_at  "2015-12-30 23:30:12"
    deadline_type { DeadlineType.first || association(:deadline_type)} 
    assignment { Assignment.first || association(:assignment)} 
    submission_allowed_id 3
    review_allowed_id  3
    resubmission_allowed_id  3
    rereview_allowed_id  3
    review_of_review_allowed_id  3
    round  1
    flag  false
    threshold  1
    delayed_job_id  nil
    deadline_name  nil
    description_url nil
    quiz_allowed_id 3
    teammate_review_allowed_id 3
  end

  factory :deadline_type ,class:DeadlineType do
    name  "submission"
  end     

  factory :deadline_right ,class:DeadlineRight do
    name  "No"
  end  

  factory :assignment_node ,class:AssignmentNode do
    assignment { Assignment.first || association(:assignment)} 
    node_object_id 1
    type "AssignmentNode"
  end  

  factory :questionnaire, class:ReviewQuestionnaire do
    name 'Test questionaire'
    instructor {User.where(role_id: 1).first || association(:instructor)} 
    private 0
    min_question_score 0
    max_question_score 5
    type 'ReviewQuestionnaire'
    display_type 'Review'
    instruction_loc nil
  end

  factory :question, class:Question do
    txt 'Test question:'
    weight 1
    questionnaire {ReviewQuestionnaire.first || association(:questionnaire)} 
    seq 1.00
    type 'Criterion'
    size "70,1"
    alternatives nil
    break_before 1
    max_label nil
    min_label nil
  end

  factory :assignment_questionnaire, class:AssignmentQuestionnaire do
    assignment { Assignment.first || association(:assignment)} 
    questionnaire {ReviewQuestionnaire.first || association(:questionnaire)} 
    user_id 1 
    questionnaire_weight 100
    used_in_round nil
    dropdown 1
  end

  factory :review_response_map, class:ReviewResponseMap do
    assignment { Assignment.first || association(:assignment)}
    reviewee {AssignmentTeam.first || association(:assignment_team)}
    reviewer_id 1       
    type 'ReviewResponseMap'
  end

  factory :response, class:Response do
    review_response_map { ReviewResponseMap.first || association(:review_response_map)}
    additional_comment nil
    version_num nil
    round nil
    is_submitted false
  end
end