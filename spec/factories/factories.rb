FactoryGirl.define do
  factory :role_of_administrator, class: Role do
    name 'Administrator'
    parent_id nil
    description ''

    # Load and cache the administrator credentials object
    cache YAML.load("---\n:credentials: !ruby/object:Credentials\nactions:\n  content_pages:\n    view_default: true\n    view: true\n    list: false\n  roles:\n    list: false\n  permissions:\n    list: false\n  auth:\n    login: true\n    logout: true\n    login_failed: true\n  menu_items:\n    link: true\n    list: false\n  site_controllers:\n    list: false\n  controller_actions:\n    list: false\n  system_settings:\n    list: false\n  users:\n    list: true\n    keys: true\n  admin:\n    list_instructors: false\n    list_administrators: false\n    list_super_administrators: false\n  course:\n    list_folders: true\n    add_ta: true\n    destroy_course: true\n    edit_course: true\n    new_course: true\n    new_folder: true\n    remove_ta: true\n    update_course: true\n    view_teaching_assistants: true\n    create_course: true\n    list: true\n  suggestion:\n    create: true\n    new: true\n  questionnaire:\n    list: true\n    create_questionnaire: true\n    edit_questionnaire: true\n    copy_questionnaire: true\n    save_questionnaire: true\n    new_quiz: true\n    create_quiz_questionnaire: true\n    update_quiz: true\n    edit_quiz: true\n    view_quiz: true\n  participants:\n    add_student: true\n    edit_team_members: true\n    list_students: true\n    list_courses: true\n    list_assignments: true\n    change_handle: true\n  assignment:\n    list: true\n  institution:\n    list: false\n  student_task:\n    list: true\n  profile:\n    edit: true\n  survey_response:\n    create: true\n    submit: true\n  team:\n    list: true\n    list_assignments: true\n  teams_users:\n    list: true\n  course_evaluation:\n    list: true\n  survey_deployment:\n    list: true\n  statistics:\n    list_surveys: true\n  impersonate:\n    start: true\n    impersonate: true\n  review_mapping:\n    list: true\n    assign_reviewer_dynamically: true\n    release_reservation: true\n    show_available_submissions: true\n    assign_metareviewer_dynamically: true\n    add_self_reviewer: true\n    assign_quiz_dynamically: true\n  tree_display:\n    list: true\n    drill: true\n    goto_questionnaires: true\n    goto_author_feedbacks: true\n    goto_review_rubrics: true\n    goto_global_survey: true\n    goto_surveys: true\n    goto_course_evaluations: true\n    goto_courses: true\n    goto_assignments: true\n    goto_teammate_reviews: true\n    goto_metareview_rubrics: true\n    goto_teammatereview_rubrics: true\n  grades:\n    view_my_scores: true\n  sign_up_sheet:\n    signup_topics: true\n    signup: true\n    delete_signup: true\n    team_details: true\n  leaderboard:\n    index: true\n  review_files:\n    show_code_file: true\n    show_code_file_diff: true\n    show_all_submitted_files: true\n    submit_comment: true\n    submit_review_file: true\n  popup:\n    automated_metareview_details_popup: true\n  advice:\n    edit_advice: true\n    save_advice: true\n  response:\n    delete: true\n  analytic:\n    assignment_list: true\n    course_list: true\n    get_graph_data_bundle: true\n    graph_data_type_list: true\n    index: true\n    init: true\n    render_sample: true\n    team_list: true\n  advertise_for_partner:\n    remove: true\n  versions:\n    revert: true\ncontrollers:\n  content_pages: false\n  controller_actions: false\n  auth: false\n  markup_styles: false\n  menu_items: false\n  permissions: false\n  roles: false\n  site_controllers: false\n  system_settings: false\n  users: true\n  roles_permissions: false\n  admin: false\n  course: true\n  assignment: true\n  questionnaire: true\n  participants: true\n  reports: true\n  institution: false\n  student_task: true\n  profile: true\n  survey_response: true\n  team: true\n  teams_users: true\n  import_file: true\n  course_evaluation: true\n  participant_choices: true\n  survey_deployment: true\n  statistics: true\n  impersonate: true\n  review_mapping: true\n  grades: true\n  tree_display: true\n  student_team: true\n  invitation: true\n  survey: true\n  password_retrieval: true\n  submitted_content: true\n  eula: true\n  student_review: true\n  publishing: true\n  export_file: true\n  response: true\n  popup: true\n  sign_up_sheet: true\n  suggestion: true\n  leaderboard: true\n  delete_object: true\n  assessment360: true\n  review_files: true\n  advertise_for_partners: true\n  join_team_requests: true\n  advertise_for_partner: true\n  automated_metareviews: true\n  advice: true\n  analytic: true\n  versions: true\n  student_quiz: true\npages:\n  home: true\n  expired: true\n  notfound: true\n  denied: true\n  contact_us: true\n  site_admin: false\n  adminpage: true\n  credits: true\n  wiki: true\npermission_ids:\n- 7\n- 7\n- 10\n- 8\n- 4\n- 3\nrole_id: 3\nrole_ids:\n- 3\n- 2\n- 6\n- 1\nupdated_at: 2015-06-11 15:23:44.000000000 Z\n")
  end

  factory :role_of_student, class: Role do
    name "Student"
    parent_id  nil
    description ""
    cache YAML.load("--- \n:credentials: !ruby/object:Credentials \n  actions: \n    content_pages: \n      view_default: true \n      view: true \n      list: false \n    roles: \n      list: false \n    permissions: \n      list: false \n    auth: \n      login: true \n      logout: true \n      login_failed: true \n    menu_items: \n      link: true \n      list: false \n    site_controllers: \n      list: false \n    controller_actions: \n      list: false \n    system_settings: \n      list: false \n    users: \n      list: false \n      keys: true \n    admin: \n      list_instructors: false \n      list_administrators: false \n      list_super_administrators: false \n    course: \n      list_folders: false \n      add_ta: false \n      destroy_course: false \n      edit_course: false \n      new_course: false \n      new_folder: false \n      remove_ta: false \n      update_course: false \n      view_teaching_assistants: false \n      create_course: false \n      list: false \n    suggestion: \n      create: true \n      new: true \n    questionnaire: \n      list: false \n      create_questionnaire: false \n      edit_questionnaire: false \n      copy_questionnaire: false \n      save_questionnaire: false \n      new_quiz: true \n      create_quiz_questionnaire: true \n      update_quiz: true \n      edit_quiz: true \n      view_quiz: true \n    participants: \n      add_student: false \n      edit_team_members: false \n      list_students: false \n      list_courses: false \n      list_assignments: false \n      change_handle: true \n    assignment: \n      list: false \n    institution: \n      list: false \n    student_task: \n      list: true \n    profile: \n      edit: true \n    survey_response: \n      create: true \n      submit: true \n    team: \n      list: false \n      list_assignments: false \n    teams_users: \n      list: false \n    course_evaluation: \n      list: true \n    survey_deployment: \n      list: false \n    statistics: \n      list_surveys: false \n    impersonate: \n      start: false \n      impersonate: true \n    review_mapping: \n      list: false \n      assign_reviewer_dynamically: true \n      release_reservation: true \n      show_available_submissions: true \n      assign_metareviewer_dynamically: true \n      add_self_reviewer: true \n      assign_quiz_dynamically: true \n    tree_display: \n      list: false \n      drill: false \n      goto_questionnaires: false \n      goto_author_feedbacks: false \n      goto_review_rubrics: false \n      goto_global_survey: false \n      goto_surveys: false \n      goto_course_evaluations: false \n      goto_courses: false \n      goto_assignments: false \n      goto_teammate_reviews: false \n      goto_metareview_rubrics: false \n      goto_teammatereview_rubrics: false \n    grades: \n      view_my_scores: true \n    sign_up_sheet: \n      signup_topics: true \n      signup: true \n      delete_signup: true \n      team_details: true \n    leaderboard: \n      index: true \n    review_files: \n      show_code_file: true \n      show_code_file_diff: true \n      show_all_submitted_files: true \n      submit_comment: true \n      submit_review_file: true \n    popup: \n      automated_metareview_details_popup: true \n    advice: \n      edit_advice: false \n      save_advice: false \n    response: \n      delete: false \n    analytic: \n      assignment_list: false \n      course_list: false \n      get_graph_data_bundle: false \n      graph_data_type_list: false \n      index: false \n      init: false \n      render_sample: false \n      team_list: false \n    advertise_for_partner: \n      remove: true \n    versions: \n      revert: true \n  controllers: \n    content_pages: false \n    controller_actions: false \n    auth: false \n    markup_styles: false \n    menu_items: false \n    permissions: false \n    roles: false \n    site_controllers: false \n    system_settings: false \n    users: true \n    roles_permissions: false \n    admin: false \n    course: false \n    assignment: false \n    questionnaire: false \n    participants: false \n    reports: true \n    institution: false \n    student_task: true \n    profile: true \n    survey_response: true \n    team: false \n    teams_users: false \n    import_file: false \n    course_evaluation: true \n    participant_choices: false \n    survey_deployment: false \n    statistics: false \n    impersonate: false \n    review_mapping: false \n    grades: false \n    tree_display: false \n    student_team: true \n    invitation: true \n    survey: false \n    password_retrieval: true \n    submitted_content: true \n    eula: true \n    student_review: true \n    publishing: true \n    export_file: false \n    response: true \n    popup: false \n    sign_up_sheet: false \n    suggestion: false \n    leaderboard: true \n    delete_object: false \n    assessment360: false \n    review_files: true \n    advertise_for_partners: true \n    join_team_requests: true \n    advertise_for_partner: true \n    automated_metareviews: true \n    advice: false \n    analytic: false \n    versions: true \n    student_quiz: true \n  pages: \n    home: true \n    expired: true \n    notfound: true \n    denied: true \n    contact_us: true \n    site_admin: false \n    adminpage: false \n    credits: true \n    wiki: true \n  permission_ids: \n  - 8 \n  - 4 \n  - 3 \n  role_id: 1 \n  role_ids: \n  - 1 \n  updated_at: 2015-06-11 15:23:43.000000000 Z \n:menu: !ruby/object:Menu \n  by_id: \n    1: &1 !ruby/object:Menu::Node \n      content_page_id: 1 \n      controller_action_id: \n      id: 1 \n      label: Home \n      name: home \n      parent: \n      parent_id: \n      site_controller_id: \n      url: '/home' \n      children: \n      - 50 \n    26: &2 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 33 \n      id: 26 \n      label: Assignments \n      name: student_task \n      parent: \n      parent_id: \n      site_controller_id: 23 \n      url: '/student_task/list' \n    30: &3 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 42 \n      id: 30 \n      label: Course Evaluation \n      name: Course Evaluation \n      parent: \n      parent_id: \n      site_controller_id: 31 \n      url: '/course_evaluation/list' \n    27: &4 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 36 \n      id: 27 \n      label: Profile \n      name: profile \n      parent: \n      parent_id: \n      site_controller_id: 26 \n      url: '/profile/edit' \n    2: &5 !ruby/object:Menu::Node \n      content_page_id: 6 \n      controller_action_id: \n      id: 2 \n      label: Contact Us \n      name: contact_us \n      parent: \n      parent_id: \n      site_controller_id: \n      url: '/contact_us' \n      children: \n      - 14 \n    50: &6 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 78 \n      id: 50 \n      label: Leaderboard \n      name: leaderboard \n      parent: \n      parent_id: 1 \n      site_controller_id: 54 \n      url: '/leaderboard/index' \n    14: &7 !ruby/object:Menu::Node \n      content_page_id: 10 \n      controller_action_id: \n      id: 14 \n      label: Credits &amp; Licence \n      name: credits \n      parent: \n      parent_id: 2 \n      site_controller_id: \n      url: '/credits' \n  by_name: \n    home: *1 \n    student_task: *2 \n    Course Evaluation: *3 \n    profile: *4 \n    contact_us: *5 \n    leaderboard: *6 \n    credits: *7 \n  crumbs: \n  - 1 \n  root: &8 !ruby/object:Menu::Node \n    parent: \n    children: \n    - 1 \n    - 26 \n    - 30 \n    - 27 \n    - 2 \n  selected: \n    1: *1 \n  vector: \n  - *8 \n  - *1")
  end

  factory :role_of_instructor, class: Role do
    name "Instructor"
    parent_id nil
    description ""
    cache YAML.load("--- \n:credentials: !ruby/object:Credentials \n  actions: \n    content_pages: \n      view_default: true \n      view: true \n      list: false \n    roles: \n      list: false \n    permissions: \n      list: false \n    auth: \n      login: true \n      logout: true \n      login_failed: true \n    menu_items: \n      link: true \n      list: false \n    site_controllers: \n      list: false \n    controller_actions: \n      list: false \n    system_settings: \n      list: false \n    users: \n      list: true \n      keys: true \n    admin: \n      list_instructors: false \n      list_administrators: false \n      list_super_administrators: false \n    course: \n      list_folders: true \n      add_ta: true \n      destroy_course: true \n      edit_course: true \n      new_course: true \n      new_folder: true \n      remove_ta: true \n      update_course: true \n      view_teaching_assistants: true \n      create_course: true \n      list: true \n    suggestion: \n      create: true \n      new: true \n    questionnaire: \n      list: true \n      create_questionnaire: true \n      edit_questionnaire: true \n      copy_questionnaire: true \n      save_questionnaire: true \n      new_quiz: true \n      create_quiz_questionnaire: true \n      update_quiz: true \n      edit_quiz: true \n      view_quiz: true \n    participants: \n      add_student: true \n      edit_team_members: true \n      list_students: true \n      list_courses: true \n      list_assignments: true \n      change_handle: true \n    assignment: \n      list: true \n    institution: \n      list: false \n    student_task: \n      list: true \n    profile: \n      edit: true \n    survey_response: \n      create: true \n      submit: true \n    team: \n      list: true \n      list_assignments: true \n    teams_users: \n      list: true \n    course_evaluation: \n      list: true \n    survey_deployment: \n      list: true \n    statistics: \n      list_surveys: true \n    impersonate: \n      start: true \n      impersonate: true \n    review_mapping: \n      list: true \n      assign_reviewer_dynamically: true \n      release_reservation: true \n      show_available_submissions: true \n      assign_metareviewer_dynamically: true \n      add_self_reviewer: true \n      assign_quiz_dynamically: true \n    tree_display: \n      list: true \n      drill: true \n      goto_questionnaires: true \n      goto_author_feedbacks: true \n      goto_review_rubrics: true \n      goto_global_survey: true \n      goto_surveys: true \n      goto_course_evaluations: true \n      goto_courses: true \n      goto_assignments: true \n      goto_teammate_reviews: true \n      goto_metareview_rubrics: true \n      goto_teammatereview_rubrics: true \n    grades: \n      view_my_scores: true \n    sign_up_sheet: \n      signup_topics: true \n      signup: true \n      delete_signup: true \n      team_details: true \n    leaderboard: \n      index: true \n    review_files: \n      show_code_file: true \n      show_code_file_diff: true \n      show_all_submitted_files: true \n      submit_comment: true \n      submit_review_file: true \n    popup: \n      automated_metareview_details_popup: true \n    advice: \n      edit_advice: true \n      save_advice: true \n    response: \n      delete: true \n    analytic: \n      assignment_list: true \n      course_list: true \n      get_graph_data_bundle: true \n      graph_data_type_list: true \n      index: true \n      init: true \n      render_sample: true \n      team_list: true \n    advertise_for_partner: \n      remove: true \n    versions: \n      revert: true \n  controllers: \n    content_pages: false \n    controller_actions: false \n    auth: false \n    markup_styles: false \n    menu_items: false \n    permissions: false \n    roles: false \n    site_controllers: false \n    system_settings: false \n    users: true \n    roles_permissions: false \n    admin: false \n    course: true \n    assignment: true \n    questionnaire: true \n    participants: true \n    reports: true \n    institution: false \n    student_task: true \n    profile: true \n    survey_response: true \n    team: true \n    teams_users: true \n    import_file: true \n    course_evaluation: true \n    participant_choices: true \n    survey_deployment: true \n    statistics: true \n    impersonate: true \n    review_mapping: true \n    grades: true \n    tree_display: true \n    student_team: true \n    invitation: true \n    survey: true \n    password_retrieval: true \n    submitted_content: true \n    eula: true \n    student_review: true \n    publishing: true \n    export_file: true \n    response: true \n    popup: true \n    sign_up_sheet: true \n    suggestion: true \n    leaderboard: true \n    delete_object: true \n    assessment360: true \n    review_files: true \n    advertise_for_partners: true \n    join_team_requests: true \n    advertise_for_partner: true \n    automated_metareviews: true \n    advice: true \n    analytic: true \n    versions: true \n    student_quiz: true \n  pages: \n    home: true \n    expired: true \n    notfound: true \n    denied: true \n    contact_us: true \n    site_admin: false \n    adminpage: true \n    credits: true \n    wiki: true \n  permission_ids: \n  - 7 \n  - 10 \n  - 8 \n  - 4 \n  - 3 \n  role_id: 2 \n  role_ids: \n  - 2 \n  - 6 \n  - 1 \n  updated_at: 2015-06-11 15:23:44.000000000 Z \n:menu: !ruby/object:Menu \n  by_id: \n    1: &1 !ruby/object:Menu::Node \n      content_page_id: 1 \n      controller_action_id: \n      id: 1 \n      label: Home \n      name: home \n      parent: \n      parent_id: \n      site_controller_id: \n      url: '/home' \n      children: \n      - 50 \n    37: &2 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 59 \n      id: 37 \n      label: Manage... \n      name: manage instructor content \n      parent: \n      parent_id: \n      site_controller_id: 38 \n      url: '/tree_display/drill' \n      children: \n      - 13 \n      - 38 \n      - 44 \n      - 45 \n      - 33 \n    35: &3 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 43 \n      id: 35 \n      label: Survey Deployments \n      name: Survey Deployments \n      parent: \n      parent_id: \n      site_controller_id: 33 \n      url: '/survey_deployment/list' \n      children: \n      - 36 \n    26: &4 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 33 \n      id: 26 \n      label: Assignments \n      name: student_task \n      parent: \n      parent_id: \n      site_controller_id: 23 \n      url: '/student_task/list' \n    30: &5 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 42 \n      id: 30 \n      label: Course Evaluation \n      name: Course Evaluation \n      parent: \n      parent_id: \n      site_controller_id: 31 \n      url: '/course_evaluation/list' \n    27: &6 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 36 \n      id: 27 \n      label: Profile \n      name: profile \n      parent: \n      parent_id: \n      site_controller_id: 26 \n      url: '/profile/edit' \n    2: &7 !ruby/object:Menu::Node \n      content_page_id: 6 \n      controller_action_id: \n      id: 2 \n      label: Contact Us \n      name: contact_us \n      parent: \n      parent_id: \n      site_controller_id: \n      url: '/contact_us' \n      children: \n      - 14 \n    50: &8 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 78 \n      id: 50 \n      label: Leaderboard \n      name: leaderboard \n      parent: \n      parent_id: 1 \n      site_controller_id: 54 \n      url: '/leaderboard/index' \n    14: &9 !ruby/object:Menu::Node \n      content_page_id: 10 \n      controller_action_id: \n      id: 14 \n      label: Credits &amp; Licence \n      name: credits \n      parent: \n      parent_id: 2 \n      site_controller_id: \n      url: '/credits' \n    46: &10 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 15 \n      id: 46 \n      label: Show... \n      name: show \n      parent: \n      parent_id: 3 \n      site_controller_id: 10 \n      url: '/users/list' \n    36: &11 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 44 \n      id: 36 \n      label: Statistical Test \n      name: Statistical Test \n      parent: \n      parent_id: 35 \n      site_controller_id: 34 \n      url: '/statistics/list_surveys' \n    13: &12 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 15 \n      id: 13 \n      label: Users \n      name: manage/users \n      parent: \n      parent_id: 37 \n      site_controller_id: 10 \n      url: '/users/list' \n    38: &13 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 60 \n      id: 38 \n      label: Questionnaires \n      name: manage/questionnaires \n      parent: \n      parent_id: 37 \n      site_controller_id: 38 \n      url: '/tree_display/goto_questionnaires' \n      children: \n      - 39 \n      - 48 \n      - 49 \n      - 40 \n      - 41 \n      - 42 \n      - 43 \n    44: &14 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 66 \n      id: 44 \n      label: Courses \n      name: manage/courses \n      parent: \n      parent_id: 37 \n      site_controller_id: 38 \n      url: '/tree_display/goto_courses' \n    45: &15 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 67 \n      id: 45 \n      label: Assignments \n      name: manage/assignments \n      parent: \n      parent_id: 37 \n      site_controller_id: 38 \n      url: '/tree_display/goto_assignments' \n    33: &16 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 45 \n      id: 33 \n      label: Impersonate User \n      name: impersonate \n      parent: \n      parent_id: 37 \n      site_controller_id: 35 \n      url: '/impersonate/start' \n    39: &17 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 62 \n      id: 39 \n      label: Review rubrics \n      name: manage/questionnaires/review rubrics \n      parent: \n      parent_id: 38 \n      site_controller_id: 38 \n      url: '/tree_display/goto_review_rubrics' \n    48: &18 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 72 \n      id: 48 \n      label: Metareview rubrics \n      name: manage/questionnaires/metareview rubrics \n      parent: \n      parent_id: 38 \n      site_controller_id: 38 \n      url: '/tree_display/goto_metareview_rubrics' \n    49: &19 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 73 \n      id: 49 \n      label: Teammate review rubrics \n      name: manage/questionnaires/teammate review rubrics \n      parent: \n      parent_id: 38 \n      site_controller_id: 38 \n      url: '/tree_display/goto_teammatereview_rubrics' \n    40: &20 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 61 \n      id: 40 \n      label: Author feedbacks \n      name: manage/questionnaires/author feedbacks \n      parent: \n      parent_id: 38 \n      site_controller_id: 38 \n      url: '/tree_display/goto_author_feedbacks' \n    41: &21 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 63 \n      id: 41 \n      label: Global survey \n      name: manage/questionnaires/global survey \n      parent: \n      parent_id: 38 \n      site_controller_id: 38 \n      url: '/tree_display/goto_global_survey' \n    42: &22 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 64 \n      id: 42 \n      label: Surveys \n      name: manage/questionnaires/surveys \n      parent: \n      parent_id: 38 \n      site_controller_id: 38 \n      url: '/tree_display/goto_surveys' \n    43: &23 !ruby/object:Menu::Node \n      content_page_id: \n      controller_action_id: 64 \n      id: 43 \n      label: Course evaluations \n      name: manage/questionnaires/course evaluations \n      parent: \n      parent_id: 38 \n      site_controller_id: 38 \n      url: '/tree_display/goto_surveys' \n  by_name: \n    home: *1 \n    manage instructor content: *2 \n    Survey Deployments: *3 \n    student_task: *4 \n    Course Evaluation: *5 \n    profile: *6 \n    contact_us: *7 \n    leaderboard: *8 \n    credits: *9 \n    show: *10 \n    Statistical Test: *11 \n    manage/users: *12 \n    manage/questionnaires: *13 \n    manage/courses: *14 \n    manage/assignments: *15 \n    impersonate: *16 \n    manage/questionnaires/review rubrics: *17 \n    manage/questionnaires/metareview rubrics: *18 \n    manage/questionnaires/teammate review rubrics: *19 \n    manage/questionnaires/author feedbacks: *20 \n    manage/questionnaires/global survey: *21 \n    manage/questionnaires/surveys: *22 \n    manage/questionnaires/course evaluations: *23 \n  crumbs: \n  - 1 \n  root: &24 !ruby/object:Menu::Node \n    parent: \n    children: \n    - 1 \n    - 37 \n    - 35 \n    - 26 \n    - 30 \n    - 27 \n    - 2 \n  selected: \n    1: *1 \n  vector: \n  - *24 \n  - *1")
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
    leaderboard_privacy false
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
    leaderboard_privacy false
    digital_certificate nil
    timezonepref 'Eastern Time (US & Canada)'
    public_key nil
    copy_of_emails  false
  end

  factory :instructor, class: User do
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
    leaderboard_privacy false
    digital_certificate nil
    timezonepref 'Eastern Time (US & Canada)'
    public_key nil
    copy_of_emails  false
  end

  factory :course, class: Course do
    sequence(:name) {|n| "CSC517, test#{n}" }
    instructor { User.where(role_id: 1).first || association(:instructor) }
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
    instructor { User.first || association(:instructor) }
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
    is_waitlisted 0
    preference_priority_number nil
  end

  factory :participant, class: Participant do
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

  factory :assignment_due_date, class: AssignmentDueDate do
    due_at "2015-12-30 23:30:12"
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
    due_at "2015-12-30 23:30:12"
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
    name 'Test questionaire'
    instructor { User.where(role_id: 1).first || association(:instructor) }
    private 0
    min_question_score 0
    max_question_score 5
    type 'ReviewQuestionnaire'
    display_type 'Review'
    instruction_loc nil
  end

  factory :metareview_questionnaire, class: MetareviewQuestionnaire do
    name 'Test questionaire'
    instructor { User.where(role_id: 1).first || association(:instructor) }
    private 0
    min_question_score 0
    max_question_score 5
    type 'MetareviewQuestionnaire'
    display_type 'Review'
    instruction_loc nil
  end

  factory :author_feedback_questionnaire, class: AuthorFeedbackQuestionnaire do
    name 'Test questionaire'
    instructor { User.where(role_id: 1).first || association(:instructor) }
    private 0
    min_question_score 0
    max_question_score 5
    type 'AuthorFeedbackQuestionnaire'
    display_type 'Review'
    instruction_loc nil
  end

  factory :teammate_review_questionnaire, class: TeammateReviewQuestionnaire do
    name 'Test questionaire'
    instructor { User.where(role_id: 1).first || association(:instructor) }
    private 0
    min_question_score 0
    max_question_score 5
    type 'TeammateReviewQuestionnaire'
    display_type 'Review'
    instruction_loc nil
  end

  factory :question, class: Question do
    txt 'Test question:'
    weight 1
    questionnaire { ReviewQuestionnaire.first || association(:questionnaire) }
    seq 1.00
    type 'Criterion'
    size "70,1"
    alternatives nil
    break_before 1
    max_label nil
    min_label nil
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
  end

  factory :response, class: Response do
    review_response_map { ReviewResponseMap.first || association(:review_response_map) }
    additional_comment nil
    version_num nil
    round nil
    is_submitted false
  end
end
