require_relative '../rails_helper'
require 'yaml'

describe "peer review testing", :type => :feature do

  before(:each) do
    @student_role = Role.where(name: 'Student').first || Role.new({name: 'Student', id: 1, cache: YAML::load('---
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
')})
    @instructor_role = Role.where(name: 'Instructor').first || Role.new({name: 'Instructor', id: 2, cache: YAML::load('---
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
')})

    @student_role.save
    @instructor_role.save

    @instructor=User.where(name: 'instructor').first || User.new({
                                                                     name: "instructor",
                                                                     password: "password",
                                                                     password_confirmation: "password",
                                                                     role_id: 2,
                                                                     fullname: "Dole, Bob",
                                                                     email: "bdole@dev.null",
                                                                     parent_id: 2,
                                                                     private_by_default: false,
                                                                     mru_directory_path: nil,
                                                                     email_on_review: true,
                                                                     email_on_submission: true,
                                                                     email_on_review_of_review: true,
                                                                     is_new_user: false,
                                                                     master_permission_granted: 0,
                                                                     handle: "",
                                                                     leaderboard_privacy: false,
                                                                     digital_certificate: nil,
                                                                     public_key: nil,
                                                                     copy_of_emails: false,
                                                                 })
    @instructor.save

    @student=User.where(name: 'student').first || User.new({
                                                               name: "student",
                                                               password: "password",
                                                               password_confirmation: "password",
                                                               role_id: 1,
                                                               fullname: "student, student",
                                                               email: "student@dev.null",
                                                               parent_id: 2,
                                                               private_by_default: false,
                                                               mru_directory_path: nil,
                                                               email_on_review: true,
                                                               email_on_submission: true,
                                                               email_on_review_of_review: true,
                                                               is_new_user: false,
                                                               master_permission_granted: 0,
                                                               handle: "",
                                                               leaderboard_privacy: false,
                                                               digital_certificate: nil,
                                                               public_key: nil,
                                                               copy_of_emails: false,
                                                           })
    @student.save

    @student2=User.where(name: 'student2').first || User.new({
                                                                 name: "student2",
                                                                 password: "password",
                                                                 password_confirmation: "password",
                                                                 role_id: 1,
                                                                 fullname: "student2, student2",
                                                                 email: "student2@dev.null",
                                                                 parent_id: 2,
                                                                 private_by_default: false,
                                                                 mru_directory_path: nil,
                                                                 email_on_review: true,
                                                                 email_on_submission: true,
                                                                 email_on_review_of_review: true,
                                                                 is_new_user: false,
                                                                 master_permission_granted: 0,
                                                                 handle: "",
                                                                 leaderboard_privacy: false,
                                                                 digital_certificate: nil,
                                                                 public_key: nil,
                                                                 copy_of_emails: false,
                                                             })
    @student2.save

    @course=Course.new({:name => "testcourse"})
    @course.save

    @deadline_type = DeadlineType.new({:name => "drop_topic"})
    @deadline_type.save

    @deadline_type_review = DeadlineType.new({:name => "review"})
    @deadline_type_review.save

    @wiki_type = WikiType.new({:name => "mediawiki"})
    @wiki_type.save

    @assignment=Assignment.new({:name => "TestAssignment", :course_id => @course.id, :instructor => @instructor, :availability_flag => 1, :wiki_type => @wiki_type, :review_assignment_strategy => 'Auto-Selected', :max_reviews_per_submission => 20})
    @assignment.save

    @deadline_right = DeadlineRight.new({:name => 'OK'})
    @deadline_right.save

    @deadline_right_no = DeadlineRight.new({:name => 'No'})
    @deadline_right_no.save

    @due_date = DueDate.new({:due_at => '2100-07-14 23:30:12', :assignment => @assignment, :deadline_type => @deadline_type_review, :review_allowed_id => @deadline_right.id, :review_of_review_allowed_id => @deadline_right_no.id, :submission_allowed_id => @deadline_right.id})
    @due_date.save

    @sign_up_topic = SignUpTopic.new({:topic_name => "TestReview", :assignment_id => @assignment.id})
    @sign_up_topic.save

    @participant=AssignmentParticipant.new({:user_id => @student.id, :parent_id => @assignment.id, :handle => 'handle', :assignment => @assignment})
    @participant.save

    @participant2=AssignmentParticipant.new({:user_id => @student2.id, :parent_id => @assignment.id, :handle => 'handle', :assignment => @assignment})
    @participant2.save

    @team1 = AssignmentTeam.new(:name => "Team2", :assignment => @assignment)
    @team1.users << @student2
    @team1.save

    @team_user1 = TeamsUser.new(:team => @team1, :user => @student2)
    @team_user1

    @team1.participants[0].submit_hyperlink "http://www.ncsu.edu"

    @signed_up_team = SignedUpTeam.new({:topic => @sign_up_topic, :team_id => @team1.id})
    @signed_up_team.save

    @quiz=Questionnaire.new({:name => "test", :instructor_id => @instructor.id, :max_question_score => "5", :min_question_score => "0", :type => "ReviewQuestionnaire"})
    @quiz.save

    @assignment_questionnaire = AssignmentQuestionnaire.new({:questionnaire => @quiz, :assignment => @assignment})
    @assignment_questionnaire.save

    @review_response_map = ReviewResponseMap.new({:assignment => @assignment, :reviewee => @team1})
    @review_response_map.save

    @response=Response.new()
    @response.save
  end

  def load_questionnaire
    visit '/'
    fill_in 'login[name]', with: 'student'
    fill_in 'login[password]', with: 'password'
    click_button 'SIGN IN'

    expect(page).to have_content "User: student"
    expect(page).to have_content "TestAssignment"

    click_link "TestAssignment"

    expect(page).to have_content "Submit or Review work for TestAssignment"
    expect(page).to have_content "Others' work"

    click_link "Others' work"

    expect(page).to have_content 'Reviews for "TestAssignment"'

    click_button "Request a new submission to review"

    choose "topic_id"
    click_button "Request a new submission to review"

    click_link "Begin"
  end

  it "fills in a single textbox and saves" do
    # Setup test specific data
    @q1=Criterion.new({:size => "70,1", :weight => 5, :questionnaire_id => @quiz.id, :seq => "3", :txt => "helloText"})
    @q1.save

    @answer_q1 = Answer.new({:question_id => @q1.id})
    @answer_q1.save

    # Load questionnaire with generic setup
    load_questionnaire

    # Fill in a textbox and a dropdown
    fill_in "responses[0][comment]", :with => "HelloWorld"
    select 5, :from => "responses[0][score]"

    click_button "Submit Review"

    expect(page).to have_content "Your response was successfully saved."
  end
it "fills in a single comment with multi word text and saves" do
    # Setup test specific data
    @q1=Criterion.new({:size => "70,1", :weight => 5, :questionnaire_id => @quiz.id, :seq => "3", :txt => "helloText"})
    @q1.save

    @answer_q1 = Answer.new({:question_id => @q1.id})
    @answer_q1.save

    # Load questionnaire with generic setup
    load_questionnaire

    # Fill in a textbox with a multi word comment 
    fill_in "responses[0][comment]", :with => "Excellent Work"
    

    click_button "Submit Review"

    expect(page).to have_content "Your response was successfully saved."
end

it "fills in a single comment with single word and saves" do
    # Setup test specific data
    @q1=Criterion.new({:size => "70,1", :weight => 5, :questionnaire_id => @quiz.id, :seq => "3", :txt => "helloText"})
    @q1.save

    @answer_q1 = Answer.new({:question_id => @q1.id})
    @answer_q1.save

    # Load questionnaire with generic setup
    load_questionnaire

    # Fill in a textbox with a single word comment
    fill_in "responses[0][comment]", :with => "Excellent"
    

    click_button "Submit Review"

    expect(page).to have_content "Your response was successfully saved."
end

it "fills in only points and saves" do
    # Setup test specific data
    @q1=Criterion.new({:size => "70,1", :weight => 5, :questionnaire_id => @quiz.id, :seq => "3", :txt => "helloText"})
    @q1.save

    @answer_q1 = Answer.new({:question_id => @q1.id})
    @answer_q1.save

    # Load questionnaire with generic setup
    load_questionnaire

    # Fill in a dropdown with some points
    select 5, :from => "responses[0][score]"
    click_button "Submit Review"

    expect(page).to have_content "Your response was successfully saved."
end  
end
