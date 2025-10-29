# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 66) do

  create_table "assignments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.string "directory_path"
    t.bigint "submitter_count", default: 0, null: false
    t.integer "course_id", default: 0, null: false
    t.integer "instructor_id", default: 0, null: false
    t.boolean "private", default: false, null: false
    t.integer "num_reviews", default: 0, null: false
    t.integer "num_review_of_reviews", default: 0, null: false
    t.integer "num_review_of_reviewers", default: 0, null: false
    t.integer "review_strategy_id", default: 0, null: false
    t.integer "mapping_strategy_id", default: 0, null: false
    t.integer "review_questionnaire_id"
    t.integer "review_of_review_questionnaire_id"
    t.float "review_weight", limit: 24
    t.boolean "reviews_visible_to_all"
    t.boolean "team_assignment"
    t.integer "wiki_type_id"
    t.boolean "require_signup"
    t.bigint "num_reviewers", default: 0, null: false
    t.text "spec_location"
    t.integer "author_feedback_questionnaire_id"
    t.boolean "max_team_count"
    t.index ["author_feedback_questionnaire_id"], name: "fk_assignments_author_feedback"
    t.index ["review_of_review_questionnaire_id"], name: "fk_assignments_review_of_review_questionnaires"
    t.index ["review_questionnaire_id"], name: "fk_assignments_review_questionnaires"
    t.index ["wiki_type_id"], name: "fk_assignments_wiki_types"
  end

  create_table "assignments_questionnaires", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "questionnaire_id", default: 0, null: false
    t.integer "assignment_id", default: 0, null: false
    t.index ["assignment_id"], name: "fk_assignments_questionnaires_assignments"
    t.index ["questionnaire_id"], name: "fk_assignments_questionnaires_questionnaires"
  end

  create_table "content_pages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "title"
    t.string "name", default: "", null: false
    t.integer "markup_style_id"
    t.text "content"
    t.integer "permission_id", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "content_cache"
    t.index ["markup_style_id"], name: "fk_content_page_markup_style_id"
    t.index ["permission_id"], name: "fk_content_page_permission_id"
  end

  create_table "controller_actions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "site_controller_id", default: 0, null: false
    t.string "name", default: "", null: false
    t.integer "permission_id"
    t.string "url_to_use"
    t.index ["permission_id"], name: "fk_controller_action_permission_id"
    t.index ["site_controller_id"], name: "fk_controller_action_site_controller_id"
  end

  create_table "courses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name"
    t.integer "instructor_id"
    t.string "directory_path"
    t.text "info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "private", default: false, null: false
    t.index ["instructor_id"], name: "fk_course_users"
  end

  create_table "courses_users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "user_id"
    t.integer "course_id"
    t.boolean "active"
    t.index ["course_id"], name: "fk_users_courses"
    t.index ["user_id"], name: "fk_courses_users"
  end

  create_table "deadline_rights", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", limit: 32
  end

  create_table "deadline_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", limit: 32
  end

  create_table "due_dates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.datetime "due_at"
    t.integer "deadline_type_id"
    t.integer "assignment_id"
    t.integer "late_policy_id"
    t.integer "submission_allowed_id"
    t.integer "review_allowed_id"
    t.integer "resubmission_allowed_id"
    t.integer "rereview_allowed_id"
    t.integer "review_of_review_allowed_id"
    t.integer "round"
    t.index ["assignment_id"], name: "fk_due_dates_assignments"
    t.index ["deadline_type_id"], name: "fk_deadline_type_due_date"
    t.index ["late_policy_id"], name: "fk_due_date_late_policies"
    t.index ["rereview_allowed_id"], name: "idx_rereview_allowed"
    t.index ["resubmission_allowed_id"], name: "idx_resubmission_allowed"
    t.index ["review_allowed_id"], name: "idx_review_allowed"
    t.index ["review_of_review_allowed_id"], name: "idx_review_of_review_allowed"
    t.index ["submission_allowed_id"], name: "idx_submission_allowed"
  end

  create_table "goldberg_content_pages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "title"
    t.string "name", default: "", null: false
    t.integer "markup_style_id"
    t.text "content"
    t.integer "permission_id", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "content_cache"
    t.string "markup_style"
    t.index ["markup_style_id"], name: "fk_content_page_markup_style_id"
    t.index ["permission_id"], name: "fk_content_page_permission_id"
  end

  create_table "goldberg_controller_actions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "site_controller_id", default: 0, null: false
    t.string "name", default: "", null: false
    t.integer "permission_id"
    t.string "url_to_use"
    t.index ["permission_id"], name: "fk_controller_action_permission_id"
    t.index ["site_controller_id"], name: "fk_controller_action_site_controller_id"
  end

  create_table "goldberg_markup_styles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
  end

  create_table "goldberg_menu_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "parent_id"
    t.string "name", default: "", null: false
    t.string "label", default: "", null: false
    t.integer "seq"
    t.integer "controller_action_id"
    t.integer "content_page_id"
    t.index ["content_page_id"], name: "fk_menu_item_content_page_id"
    t.index ["controller_action_id"], name: "fk_menu_item_controller_action_id"
    t.index ["parent_id"], name: "fk_menu_item_parent_id"
  end

  create_table "goldberg_permissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
  end

  create_table "goldberg_roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
    t.integer "parent_id"
    t.string "description", default: "", null: false
    t.integer "default_page_id"
    t.text "cache"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "start_path"
    t.index ["default_page_id"], name: "fk_role_default_page_id"
    t.index ["parent_id"], name: "fk_role_parent_id"
  end

  create_table "goldberg_roles_permissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "role_id", default: 0, null: false
    t.integer "permission_id", default: 0, null: false
    t.index ["permission_id"], name: "fk_roles_permission_permission_id"
    t.index ["role_id"], name: "fk_roles_permission_role_id"
  end

  create_table "goldberg_site_controllers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
    t.integer "permission_id", default: 0, null: false
    t.integer "builtin", default: 0
    t.index ["permission_id"], name: "fk_site_controller_permission_id"
  end

  create_table "goldberg_system_settings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "site_name", default: "", null: false
    t.string "site_subtitle"
    t.string "footer_message", default: ""
    t.integer "public_role_id", default: 0, null: false
    t.integer "session_timeout", default: 0, null: false
    t.integer "default_markup_style_id", default: 0
    t.integer "site_default_page_id", default: 0, null: false
    t.integer "not_found_page_id", default: 0, null: false
    t.integer "permission_denied_page_id", default: 0, null: false
    t.integer "session_expired_page_id", default: 0, null: false
    t.integer "menu_depth", default: 0, null: false
    t.string "start_path"
    t.string "site_url_prefix"
    t.boolean "self_reg_enabled"
    t.integer "self_reg_role_id"
    t.boolean "self_reg_confirmation_required"
    t.integer "self_reg_confirmation_error_page_id"
    t.boolean "self_reg_send_confirmation_email"
    t.index ["not_found_page_id"], name: "fk_system_settings_not_found_page_id"
    t.index ["permission_denied_page_id"], name: "fk_system_settings_permission_denied_page_id"
    t.index ["public_role_id"], name: "fk_system_settings_public_role_id"
    t.index ["session_expired_page_id"], name: "fk_system_settings_session_expired_page_id"
    t.index ["site_default_page_id"], name: "fk_system_settings_site_default_page_id"
  end

  create_table "goldberg_users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
    t.string "password", limit: 40, default: "", null: false
    t.integer "role_id", default: 0, null: false
    t.string "password_salt"
    t.string "fullname"
    t.string "email"
    t.string "start_path"
    t.boolean "self_reg_confirmation_required"
    t.string "confirmation_key"
    t.datetime "password_changed_at"
    t.boolean "password_expired"
    t.index ["role_id"], name: "fk_user_role_id"
  end

  create_table "institutions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
  end

  create_table "invitations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "assignment_id"
    t.integer "from_id"
    t.integer "to_id"
    t.string "reply_status", limit: 1
    t.index ["assignment_id"], name: "fk_invitation_assignments"
    t.index ["from_id"], name: "fk_invitationfrom_users"
    t.index ["to_id"], name: "fk_invitationto_users"
  end

  create_table "languages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", limit: 32
  end

  create_table "late_policies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "penalty_period_in_minutes"
    t.integer "penalty_per_unit"
    t.boolean "expressed_as_percentage"
    t.integer "max_penalty", default: 0, null: false
    t.index ["penalty_period_in_minutes"], name: "penalty_period_length_unit"
  end

  create_table "mapping_strategies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name"
  end

  create_table "markup_styles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
  end

  create_table "menu_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "parent_id"
    t.string "name", default: "", null: false
    t.string "label", default: "", null: false
    t.integer "seq"
    t.integer "controller_action_id"
    t.integer "content_page_id"
    t.index ["content_page_id"], name: "fk_menu_item_content_page_id"
    t.index ["controller_action_id"], name: "fk_menu_item_controller_action_id"
    t.index ["parent_id"], name: "fk_menu_item_parent_id"
  end

  create_table "nodes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "parent_id"
    t.integer "node_object_id"
    t.string "type"
    t.string "name"
    t.integer "lft"
    t.integer "rgt"
    t.integer "depth"
  end

  create_table "participants", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.boolean "submit_allowed", default: true
    t.boolean "review_allowed", default: true
    t.integer "user_id"
    t.integer "parent_id"
    t.integer "directory_num"
    t.datetime "submitted_at"
    t.string "topic"
    t.boolean "permission_granted"
    t.bigint "penalty_accumulated", default: 0, null: false
    t.string "submitted_hyperlink", limit: 100
    t.float "grade", limit: 24
    t.text "comments_to_student"
    t.text "private_instructor_comments"
    t.string "type"
    t.index ["user_id"], name: "fk_participant_users"
  end

  create_table "permissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
  end

  create_table "plugin_schema_info", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "plugin_name"
    t.integer "version"
  end

  create_table "question_advices", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "question_id"
    t.integer "score"
    t.text "advice"
    t.index ["question_id"], name: "fk_question_question_advices"
  end

  create_table "questionnaire_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
  end

  create_table "questionnaires", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", limit: 64
    t.integer "instructor_id", default: 0, null: false
    t.boolean "private", default: false, null: false
    t.integer "min_question_score", default: 0, null: false
    t.integer "max_question_score"
    t.datetime "created_at"
    t.datetime "updated_at", null: false
    t.integer "default_num_choices"
    t.integer "type_id", default: 1, null: false
    t.index ["type_id"], name: "fk_questionnaire_type"
  end

  create_table "questions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.text "txt"
    t.boolean "true_false"
    t.integer "weight"
    t.integer "questionnaire_id"
    t.index ["questionnaire_id"], name: "fk_question_questionnaires"
  end

  create_table "resubmission_times", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "participant_id"
    t.datetime "resubmitted_at"
    t.index ["participant_id"], name: "fk_resubmission_times_participants"
  end

  create_table "review_feedbacks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "assignment_id"
    t.integer "review_id"
    t.integer "author_id"
    t.datetime "feedback_at"
    t.text "additional_comment"
    t.index ["assignment_id"], name: "fk_review_feedback_assignments"
    t.index ["review_id"], name: "fk_review_feedback_reviews"
  end

  create_table "review_mappings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "author_id"
    t.integer "team_id"
    t.integer "reviewer_id"
    t.integer "assignment_id"
    t.integer "round"
    t.index ["assignment_id"], name: "fk_review_mapping_assignments"
    t.index ["author_id"], name: "fk_review_users_author"
    t.index ["reviewer_id"], name: "fk_review_users_reviewer"
    t.index ["team_id"], name: "fk_review_teams"
  end

  create_table "review_of_review_mappings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "review_mapping_id"
    t.integer "review_reviewer_id"
    t.index ["review_mapping_id"], name: "fk_review_of_review_mapping_review_mappings"
  end

  create_table "review_of_review_scores", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "review_of_review_id"
    t.integer "question_id"
    t.integer "score"
    t.text "comments"
    t.index ["question_id"], name: "fk_review_of_review_score_questions"
    t.index ["review_of_review_id"], name: "fk_review_of_review_score_reviews"
  end

  create_table "review_of_reviews", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.datetime "reviewed_at"
    t.integer "review_of_review_mapping_id"
    t.integer "review_num_for_author"
    t.integer "review_num_for_reviewer"
    t.index ["review_of_review_mapping_id"], name: "fk_review_of_review_review_of_review_mappings"
  end

  create_table "review_scores", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "review_id"
    t.integer "question_id"
    t.integer "score"
    t.text "comments"
    t.integer "questionnaire_type_id"
    t.index ["question_id"], name: "fk_review_score_questions"
    t.index ["questionnaire_type_id"], name: "fk_review_scores_questionnaire_type_id"
    t.index ["review_id"], name: "fk_review_score_reviews"
  end

  create_table "review_strategies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name"
  end

  create_table "reviews", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "review_mapping_id"
    t.integer "review_num_for_author"
    t.integer "review_num_for_reviewer"
    t.boolean "ignore", default: false
    t.text "additional_comment"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["review_mapping_id"], name: "fk_review_mappings"
  end

  create_table "roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
    t.integer "parent_id"
    t.string "description", default: "", null: false
    t.integer "default_page_id"
    t.text "cache"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["default_page_id"], name: "fk_role_default_page_id"
    t.index ["parent_id"], name: "fk_role_parent_id"
  end

  create_table "roles_permissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "role_id", default: 0, null: false
    t.integer "permission_id", default: 0, null: false
    t.index ["permission_id"], name: "fk_roles_permission_permission_id"
    t.index ["role_id"], name: "fk_roles_permission_role_id"
  end

  create_table "site_controllers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
    t.integer "permission_id", default: 0, null: false
    t.integer "builtin", default: 0
    t.index ["permission_id"], name: "fk_site_controller_permission_id"
  end

  create_table "survey_deployments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "course_evaluation_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "num_of_students"
    t.datetime "last_reminder"
  end

  create_table "survey_responses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.bigint "score"
    t.text "comments"
    t.bigint "assignment_id", default: 0, null: false
    t.bigint "question_id", default: 0, null: false
    t.bigint "survey_id", default: 0, null: false
    t.string "email"
    t.integer "survey_deployment_id"
    t.index ["assignment_id"], name: "fk_survey_assignments"
    t.index ["question_id"], name: "fk_survey_questions"
    t.index ["survey_id"], name: "fk_survey_questionnaires"
  end

  create_table "system_settings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "site_name", default: "", null: false
    t.string "site_subtitle"
    t.string "footer_message", default: ""
    t.integer "public_role_id", default: 0, null: false
    t.integer "session_timeout", default: 0, null: false
    t.integer "default_markup_style_id", default: 0
    t.integer "site_default_page_id", default: 0, null: false
    t.integer "not_found_page_id", default: 0, null: false
    t.integer "permission_denied_page_id", default: 0, null: false
    t.integer "session_expired_page_id", default: 0, null: false
    t.integer "menu_depth", default: 0, null: false
    t.index ["not_found_page_id"], name: "fk_system_settings_not_found_page_id"
    t.index ["permission_denied_page_id"], name: "fk_system_settings_permission_denied_page_id"
    t.index ["public_role_id"], name: "fk_system_settings_public_role_id"
    t.index ["session_expired_page_id"], name: "fk_system_settings_session_expired_page_id"
    t.index ["site_default_page_id"], name: "fk_system_settings_site_default_page_id"
  end

  create_table "ta_mappings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "ta_id"
    t.integer "course_id"
    t.index ["course_id"], name: "fk_ta_mappings_course_id"
    t.index ["ta_id"], name: "fk_ta_mappings_ta_id"
  end

  create_table "teams", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name"
    t.integer "parent_id", default: 0, null: false
    t.string "type"
  end

  create_table "teams_users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.integer "team_id"
    t.integer "user_id"
    t.index ["team_id"], name: "fk_users_teams"
    t.index ["user_id"], name: "fk_teams_users"
  end

  create_table "tree_folders", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name"
    t.string "child_type"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
    t.string "password", limit: 40, default: "", null: false
    t.integer "role_id", default: 0, null: false
    t.string "password_salt"
    t.string "fullname"
    t.string "email"
    t.integer "parent_id"
    t.boolean "private_by_default", default: false
    t.string "mru_directory_path", limit: 128
    t.boolean "email_on_review"
    t.boolean "email_on_submission"
    t.boolean "email_on_review_of_review"
    t.boolean "is_new_user", default: true
    t.boolean "master_permission_granted"
    t.index ["role_id"], name: "fk_user_role_id"
  end

  create_table "versions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "wiki_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci" do |t|
    t.string "name", default: "", null: false
  end

  add_foreign_key "assignments", "questionnaire_types", column: "author_feedback_questionnaire_id", name: "fk_assignments_author_feedback"
  add_foreign_key "assignments", "questionnaires", column: "review_of_review_questionnaire_id", name: "fk_assignments_review_of_review_questionnaires"
  add_foreign_key "assignments", "questionnaires", column: "review_questionnaire_id", name: "fk_assignments_review_questionnaires"
  add_foreign_key "assignments", "wiki_types", name: "fk_assignments_wiki_types"
  add_foreign_key "assignments_questionnaires", "assignments", name: "fk_assignments_questionnaires_assignments"
  add_foreign_key "assignments_questionnaires", "questionnaires", name: "fk_assignments_questionnaires_questionnaires"
  add_foreign_key "courses", "users", column: "instructor_id", name: "fk_course_users"
  add_foreign_key "courses_users", "courses", name: "fk_users_courses"
  add_foreign_key "courses_users", "users", name: "fk_courses_users"
  add_foreign_key "due_dates", "assignments", name: "fk_due_dates_assignments"
  add_foreign_key "due_dates", "deadline_types", name: "fk_deadline_type_due_date"
  add_foreign_key "due_dates", "late_policies", name: "fk_due_date_late_policies"
  add_foreign_key "invitations", "assignments", name: "fk_invitation_assignments"
  add_foreign_key "invitations", "users", column: "from_id", name: "fk_invitationfrom_users"
  add_foreign_key "invitations", "users", column: "to_id", name: "fk_invitationto_users"
  add_foreign_key "participants", "users", name: "fk_participant_users"
  add_foreign_key "question_advices", "questions", name: "fk_question_question_advices"
  add_foreign_key "questionnaires", "questionnaire_types", column: "type_id", name: "fk_questionnaire_type"
  add_foreign_key "questions", "questionnaires", name: "fk_question_questionnaires"
  add_foreign_key "resubmission_times", "participants", name: "fk_resubmission_times_participants"
  add_foreign_key "review_feedbacks", "assignments", name: "fk_review_feedback_assignments"
  add_foreign_key "review_feedbacks", "reviews", name: "fk_review_feedback_reviews"
  add_foreign_key "review_mappings", "assignments", name: "fk_review_mapping_assignments"
  add_foreign_key "review_mappings", "teams", name: "fk_review_teams"
  add_foreign_key "review_mappings", "users", column: "author_id", name: "fk_review_users_author"
  add_foreign_key "review_mappings", "users", column: "reviewer_id", name: "fk_review_users_reviewer"
  add_foreign_key "review_of_review_scores", "questions", name: "fk_review_of_review_score_questions"
  add_foreign_key "review_of_review_scores", "review_of_reviews", name: "fk_review_of_review_score_reviews"
  add_foreign_key "review_of_reviews", "review_of_review_mappings", name: "fk_review_of_review_review_of_review_mappings"
  add_foreign_key "review_scores", "questionnaire_types", name: "fk_review_scores_questionnaire_type_id"
  add_foreign_key "review_scores", "questions", name: "fk_review_score_questions"
  add_foreign_key "review_scores", "reviews", name: "fk_review_score_reviews"
  add_foreign_key "reviews", "review_mappings", name: "fk_review_mappings"
  add_foreign_key "ta_mappings", "courses", name: "fk_ta_mappings_course_id"
  add_foreign_key "ta_mappings", "users", column: "ta_id", name: "fk_ta_mappings_ta_id"
  add_foreign_key "teams_users", "teams", name: "fk_users_teams"
  add_foreign_key "teams_users", "users", name: "fk_teams_users"
end
