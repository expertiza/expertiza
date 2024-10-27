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

ActiveRecord::Schema.define(version: 20241009142307) do

  create_table "account_requests", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "username"
    t.integer "role_id"
    t.string "fullname"
    t.string "institution_id"
    t.string "email"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "self_introduction"
  end

  create_table "answer_tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "answer_id"
    t.integer "tag_prompt_deployment_id"
    t.integer "user_id"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "confidence_level", precision: 10, scale: 5
    t.index ["answer_id"], name: "index_answer_tags_on_answer_id"
    t.index ["tag_prompt_deployment_id"], name: "index_answer_tags_on_tag_prompt_deployment_id"
    t.index ["user_id"], name: "index_answer_tags_on_user_id"
  end

  create_table "answers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "question_id", default: 0, null: false
    t.integer "answer"
    t.text "comments"
    t.integer "response_id"
    t.index ["question_id"], name: "fk_score_questions"
    t.index ["response_id"], name: "fk_score_response"
  end

  create_table "assignment_badges", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "badge_id"
    t.integer "assignment_id"
    t.integer "threshold"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_assignment_badges_on_assignment_id"
    t.index ["badge_id"], name: "index_assignment_badges_on_badge_id"
  end

  create_table "assignment_questionnaires", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "assignment_id"
    t.integer "questionnaire_id"
    t.integer "user_id"
    t.integer "notification_limit", default: 15, null: false
    t.integer "questionnaire_weight", default: 0, null: false
    t.integer "used_in_round"
    t.boolean "dropdown", default: true
    t.integer "topic_id"
    t.integer "duty_id"
    t.index ["assignment_id"], name: "fk_aq_assignments_id"
    t.index ["duty_id"], name: "index_assignment_questionnaires_on_duty_id"
    t.index ["questionnaire_id"], name: "fk_aq_questionnaire_id"
    t.index ["user_id"], name: "fk_aq_user_id"
  end

  create_table "assignments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.string "directory_path"
    t.integer "submitter_count", default: 0, null: false, unsigned: true
    t.integer "course_id", default: 0
    t.integer "instructor_id", default: 0
    t.boolean "private", default: false, null: false
    t.integer "num_reviews", default: 3, null: false
    t.integer "num_review_of_reviews", default: 0, null: false, unsigned: true
    t.integer "num_review_of_reviewers", default: 0, null: false
    t.boolean "reviews_visible_to_all"
    t.integer "num_reviewers", default: 0, null: false, unsigned: true
    t.text "spec_location"
    t.integer "max_team_size", default: 0, null: false
    t.boolean "staggered_deadline"
    t.boolean "allow_suggestions"
    t.integer "days_between_submissions"
    t.string "review_assignment_strategy"
    t.integer "max_reviews_per_submission"
    t.integer "review_topic_threshold", default: 0
    t.boolean "copy_flag", default: false
    t.integer "rounds_of_reviews", default: 1
    t.boolean "microtask", default: false
    t.boolean "require_quiz"
    t.integer "num_quiz_questions", default: 0, null: false
    t.boolean "is_coding_assignment"
    t.boolean "is_intelligent"
    t.boolean "calculate_penalty", default: false, null: false
    t.integer "late_policy_id"
    t.boolean "is_penalty_calculated", default: false, null: false
    t.integer "max_bids"
    t.boolean "show_teammate_reviews"
    t.boolean "availability_flag", default: true
    t.boolean "use_bookmark"
    t.boolean "can_review_same_topic", default: true
    t.boolean "can_choose_topic_to_review", default: true
    t.boolean "is_calibrated", default: false
    t.boolean "is_selfreview_enabled"
    t.string "reputation_algorithm", default: "Lauw"
    t.boolean "is_anonymous", default: true
    t.integer "num_reviews_required", default: 3
    t.integer "num_metareviews_required", default: 3
    t.integer "num_metareviews_allowed", default: 3
    t.integer "num_reviews_allowed", default: 3
    t.integer "simicheck", default: -1
    t.integer "simicheck_threshold", default: 100
    t.boolean "is_answer_tagging_allowed"
    t.boolean "has_badge"
    t.boolean "allow_selecting_additional_reviews_after_1st_round"
    t.integer "sample_assignment_id"
    t.boolean "vary_by_topic?", default: false
    t.boolean "vary_by_round?", default: false
    t.boolean "team_reviewing_enabled", default: false
    t.boolean "bidding_for_reviews_enabled", default: false
    t.boolean "is_conference_assignment", default: false
    t.boolean "auto_assign_mentor", default: false
    t.boolean "duty_based_assignment?"
    t.boolean "questionnaire_varies_by_duty"
    t.boolean "enable_pair_programming", default: false
    t.index ["course_id"], name: "fk_assignments_courses"
    t.index ["instructor_id"], name: "fk_assignments_instructors"
    t.index ["late_policy_id"], name: "fk_late_policy_id"
    t.index ["sample_assignment_id"], name: "fk_rails_b01b82a1a2"
  end

  create_table "assignments_questionnaires", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.integer "questionnaire_id", default: 0, null: false
    t.integer "assignment_id", default: 0, null: false
    t.index ["assignment_id"], name: "fk_assignments_questionnaires_assignments"
    t.index ["questionnaire_id"], name: "fk_assignments_questionnaires_questionnaires"
  end

  create_table "automated_metareviews", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.float "relevance", limit: 24
    t.float "content_summative", limit: 24
    t.float "content_problem", limit: 24
    t.float "content_advisory", limit: 24
    t.float "tone_positive", limit: 24
    t.float "tone_negative", limit: 24
    t.float "tone_neutral", limit: 24
    t.integer "quantity"
    t.integer "plagiarism"
    t.integer "version_num"
    t.integer "response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["response_id"], name: "fk_automated_metareviews_responses_id"
  end

  create_table "awarded_badges", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "badge_id"
    t.integer "participant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "approval_status"
    t.index ["badge_id"], name: "index_awarded_badges_on_badge_id"
    t.index ["participant_id"], name: "index_awarded_badges_on_participant_id"
  end

  create_table "badges", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.string "description"
    t.string "image_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bids", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "topic_id"
    t.integer "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "priority"
    t.index ["team_id"], name: "index_bids_on_team_id"
    t.index ["topic_id"], name: "index_bids_on_topic_id"
  end

  create_table "bookmark_ratings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "bookmark_id"
    t.integer "user_id"
    t.integer "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookmarks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text "url"
    t.text "title"
    t.text "description"
    t.integer "user_id"
    t.integer "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["topic_id"], name: "index_bookmarks_on_topic_id"
  end

  create_table "calculated_penalties", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "participant_id"
    t.integer "deadline_type_id"
    t.integer "penalty_points"
  end

  create_table "content_pages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
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

  create_table "controller_actions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "site_controller_id", default: 0, null: false
    t.string "name", default: "", null: false
    t.integer "permission_id"
    t.string "url_to_use"
    t.index ["permission_id"], name: "fk_controller_action_permission_id"
    t.index ["site_controller_id"], name: "fk_controller_action_site_controller_id"
  end

  create_table "courses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.integer "instructor_id"
    t.string "directory_path"
    t.text "info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "private", default: false, null: false
    t.integer "institutions_id"
    t.integer "locale", default: 1
    t.index ["instructor_id"], name: "fk_course_users"
  end

  create_table "courses_users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "course_id"
    t.boolean "active"
    t.index ["course_id"], name: "fk_users_courses"
    t.index ["user_id"], name: "fk_courses_users"
  end

  create_table "deadline_rights", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", limit: 32
  end

  create_table "deadline_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", limit: 32
  end

  create_table "delayed_jobs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "queue"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "due_dates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.datetime "due_at"
    t.integer "deadline_type_id"
    t.integer "parent_id"
    t.integer "submission_allowed_id"
    t.integer "review_allowed_id"
    t.integer "review_of_review_allowed_id"
    t.integer "round"
    t.boolean "flag", default: false
    t.integer "threshold", default: 1
    t.string "delayed_job_id"
    t.string "deadline_name"
    t.string "description_url"
    t.integer "quiz_allowed_id", default: 1
    t.integer "teammate_review_allowed_id", default: 3
    t.string "type", default: "AssignmentDueDate"
    t.index ["deadline_type_id"], name: "fk_deadline_type_due_date"
    t.index ["parent_id"], name: "fk_due_dates_assignments"
    t.index ["review_allowed_id"], name: "fk_due_date_review_allowed"
    t.index ["review_of_review_allowed_id"], name: "fk_due_date_review_of_review_allowed"
    t.index ["submission_allowed_id"], name: "fk_due_date_submission_allowed"
  end

  create_table "duties", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.integer "max_members_for_duty"
    t.integer "assignment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_duties_on_assignment_id"
  end

  create_table "goldberg_content_pages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
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

  create_table "goldberg_controller_actions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.integer "site_controller_id", default: 0, null: false
    t.string "name", default: "", null: false
    t.integer "permission_id"
    t.string "url_to_use"
    t.index ["permission_id"], name: "fk_controller_action_permission_id"
    t.index ["site_controller_id"], name: "fk_controller_action_site_controller_id"
  end

  create_table "goldberg_markup_styles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.string "name", default: "", null: false
  end

  create_table "goldberg_menu_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
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

  create_table "goldberg_permissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.string "name", default: "", null: false
  end

  create_table "goldberg_roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
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

  create_table "goldberg_roles_permissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.integer "role_id", default: 0, null: false
    t.integer "permission_id", default: 0, null: false
    t.index ["permission_id"], name: "fk_roles_permission_permission_id"
    t.index ["role_id"], name: "fk_roles_permission_role_id"
  end

  create_table "goldberg_site_controllers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.string "name", default: "", null: false
    t.integer "permission_id", default: 0, null: false
    t.integer "builtin", default: 0
    t.index ["permission_id"], name: "fk_site_controller_permission_id"
  end

  create_table "goldberg_system_settings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
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

  create_table "goldberg_users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
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

  create_table "institutions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", default: "", null: false
  end

  create_table "invitations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "assignment_id"
    t.integer "from_id"
    t.integer "to_id"
    t.string "reply_status", limit: 1
    t.index ["assignment_id"], name: "fk_invitation_assignments"
    t.index ["from_id"], name: "fk_invitationfrom_users"
    t.index ["to_id"], name: "fk_invitationto_users"
  end

  create_table "join_team_requests", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "participant_id"
    t.integer "team_id"
    t.text "comments"
    t.string "status", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", limit: 32
  end

  create_table "late_policies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.float "penalty_per_unit", limit: 24
    t.integer "max_penalty", default: 0, null: false
    t.string "penalty_unit", null: false
    t.integer "times_used", default: 0, null: false
    t.integer "instructor_id", null: false
    t.string "policy_name", null: false
    t.boolean "private", default: true, null: false
    t.index ["instructor_id"], name: "fk_instructor_id"
  end

  create_table "locks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "timeout_period"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.string "lockable_type"
    t.integer "lockable_id"
    t.index ["user_id"], name: "fk_rails_426f571216"
  end

  create_table "mapping_strategies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.string "name"
  end

  create_table "markup_styles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", default: "", null: false
  end

  create_table "menu_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
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

  create_table "nodes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "parent_id"
    t.integer "node_object_id"
    t.string "type"
  end

  create_table "notifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string "subject"
    t.text "description"
    t.date "expiration_date"
    t.boolean "active_flag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "course_id"
    t.index ["course_id"], name: "index_notifications_on_course_id"
  end

  create_table "participants", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.boolean "can_submit", default: true
    t.boolean "can_review", default: true
    t.integer "user_id"
    t.integer "parent_id"
    t.datetime "submitted_at"
    t.boolean "permission_granted"
    t.integer "penalty_accumulated", default: 0, null: false, unsigned: true
    t.float "grade", limit: 24
    t.string "type"
    t.string "handle"
    t.datetime "time_stamp"
    t.text "digital_signature"
    t.string "duty"
    t.boolean "can_take_quiz", default: true
    t.float "Hamer", limit: 24, default: 1.0
    t.float "Lauw", limit: 24, default: 0.0
    t.integer "duty_id"
    t.boolean "can_mentor", default: false
    t.index ["duty_id"], name: "index_participants_on_duty_id"
    t.index ["user_id"], name: "fk_participant_users"
  end

  create_table "password_resets", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string "user_email"
    t.string "token"
    t.datetime "updated_at"
  end

  create_table "permissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", default: "", null: false
  end

  create_table "plagiarism_checker_assignment_submissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string "name"
    t.string "simicheck_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assignment_id"
    t.index ["assignment_id"], name: "index_plagiarism_checker_assgt_subm_on_assignment_id"
  end

  create_table "plagiarism_checker_comparisons", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer "plagiarism_checker_assignment_submission_id"
    t.string "similarity_link"
    t.decimal "similarity_percentage", precision: 10
    t.string "file1_name"
    t.string "file1_id"
    t.string "file1_team"
    t.string "file2_name"
    t.string "file2_id"
    t.string "file2_team"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plagiarism_checker_assignment_submission_id"], name: "assignment_submission_index"
  end

  create_table "plugin_schema_info", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.string "plugin_name"
    t.integer "version"
  end

  create_table "question_advices", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "question_id"
    t.integer "score"
    t.text "advice"
    t.index ["question_id"], name: "fk_question_question_advices"
  end

  create_table "question_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "type"
  end

  create_table "questionnaire_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.string "name", default: "", null: false
  end

  create_table "questionnaires", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", limit: 64
    t.integer "instructor_id", default: 0, null: false
    t.boolean "private", default: false, null: false
    t.integer "min_question_score", default: 0, null: false
    t.integer "max_question_score"
    t.datetime "created_at"
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "display_type"
    t.text "instruction_loc"
  end

  create_table "questions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text "txt"
    t.integer "weight"
    t.integer "questionnaire_id"
    t.decimal "seq", precision: 6, scale: 2
    t.string "type"
    t.string "size", default: ""
    t.string "alternatives"
    t.boolean "break_before", default: true
    t.string "max_label", default: ""
    t.string "min_label", default: ""
    t.index ["questionnaire_id"], name: "fk_question_questionnaires"
  end

  create_table "quiz_question_choices", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "question_id"
    t.text "txt"
    t.boolean "iscorrect", default: false
  end

  create_table "response_maps", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "reviewed_object_id", default: 0, null: false
    t.integer "reviewer_id", default: 0, null: false
    t.integer "reviewee_id", default: 0, null: false
    t.string "type", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "calibrate_to", default: false
    t.boolean "team_reviewing_enabled", default: false
    t.index ["reviewer_id"], name: "fk_response_map_reviewer"
  end

  create_table "responses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "map_id", default: 0, null: false
    t.text "additional_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "version_num"
    t.integer "round"
    t.boolean "is_submitted", default: false
    t.string "visibility", default: "private"
    t.index ["map_id"], name: "fk_response_response_map"
  end

  create_table "resubmission_times", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "participant_id"
    t.datetime "resubmitted_at"
    t.index ["participant_id"], name: "fk_resubmission_times_participants"
  end

  create_table "review_bids", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "priority"
    t.integer "signuptopic_id"
    t.integer "participant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "assignment_id"
    t.index ["assignment_id"], name: "fk_rails_549e23ae08"
    t.index ["participant_id"], name: "fk_rails_ab93feeb35"
    t.index ["signuptopic_id"], name: "fk_rails_e88fa4058f"
    t.index ["user_id"], name: "fk_rails_6041e1cdb9"
  end

  create_table "review_comment_paste_bins", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer "review_grade_id"
    t.string "title"
    t.text "review_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["review_grade_id"], name: "fk_rails_0a539bcc81"
  end

  create_table "review_feedbacks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.integer "assignment_id"
    t.integer "review_id"
    t.integer "author_id"
    t.datetime "feedback_at"
    t.text "additional_comment"
    t.index ["assignment_id"], name: "fk_review_feedback_assignments"
    t.index ["review_id"], name: "fk_review_feedback_reviews"
  end

  create_table "review_grades", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer "participant_id"
    t.integer "grade_for_reviewer"
    t.text "comment_for_reviewer"
    t.datetime "review_graded_at"
    t.integer "reviewer_id"
    t.index ["participant_id"], name: "fk_rails_29587cf6a9"
  end

  create_table "review_mappings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
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

  create_table "review_of_review_mappings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.integer "review_mapping_id"
    t.integer "review_reviewer_id"
    t.index ["review_mapping_id"], name: "fk_review_of_review_mapping_review_mappings"
  end

  create_table "review_of_review_scores", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.integer "review_of_review_id"
    t.integer "question_id"
    t.integer "score"
    t.text "comments"
    t.index ["question_id"], name: "fk_review_of_review_score_questions"
    t.index ["review_of_review_id"], name: "fk_review_of_review_score_reviews"
  end

  create_table "review_of_reviews", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.datetime "reviewed_at"
    t.integer "review_of_review_mapping_id"
    t.integer "review_num_for_author"
    t.integer "review_num_for_reviewer"
    t.index ["review_of_review_mapping_id"], name: "fk_review_of_review_review_of_review_mappings"
  end

  create_table "review_scores", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.integer "review_id"
    t.integer "question_id"
    t.integer "score"
    t.text "comments"
    t.integer "questionnaire_type_id"
    t.index ["question_id"], name: "fk_review_score_questions"
    t.index ["questionnaire_type_id"], name: "fk_review_scores_questionnaire_type_id"
    t.index ["review_id"], name: "fk_review_score_reviews"
  end

  create_table "review_strategies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.string "name"
  end

  create_table "reviews", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.integer "review_mapping_id"
    t.integer "review_num_for_author"
    t.integer "review_num_for_reviewer"
    t.boolean "ignore", default: false
    t.text "additional_comment"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["review_mapping_id"], name: "fk_review_mappings"
  end

  create_table "roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", default: "", null: false
    t.integer "parent_id"
    t.string "description", default: "", null: false
    t.integer "default_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["default_page_id"], name: "fk_role_default_page_id"
    t.index ["parent_id"], name: "fk_role_parent_id"
  end

  create_table "roles_permissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "role_id", default: 0, null: false
    t.integer "permission_id", default: 0, null: false
    t.index ["permission_id"], name: "fk_roles_permission_permission_id"
    t.index ["role_id"], name: "fk_roles_permission_role_id"
  end

  create_table "sample_reviews", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "assignment_id"
    t.integer "response_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.string "name", null: false
    t.text "desc_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "session_id", default: "", null: false
    t.text "data", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sign_up_topics", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text "topic_name", null: false
    t.integer "assignment_id", default: 0, null: false
    t.integer "max_choosers", default: 0, null: false
    t.text "category"
    t.string "topic_identifier", limit: 10
    t.integer "micropayment", default: 0
    t.integer "private_to"
    t.text "description"
    t.string "link"
    t.index ["assignment_id"], name: "fk_sign_up_categories_sign_up_topics"
    t.index ["assignment_id"], name: "index_sign_up_topics_on_assignment_id"
  end

  create_table "signed_up_teams", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "topic_id", default: 0, null: false
    t.integer "team_id", default: 0, null: false
    t.boolean "is_waitlisted", default: false, null: false
    t.integer "preference_priority_number"
    t.index ["topic_id"], name: "fk_signed_up_users_sign_up_topics"
  end

  create_table "site_controllers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", default: "", null: false
    t.integer "permission_id", default: 0, null: false
    t.integer "builtin", default: 0
    t.index ["permission_id"], name: "fk_site_controller_permission_id"
  end

  create_table "submission_records", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "type"
    t.string "content"
    t.string "operation"
    t.integer "team_id"
    t.string "user"
    t.integer "assignment_id"
  end

  create_table "suggestion_comments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text "comments"
    t.string "commenter"
    t.string "vote"
    t.integer "suggestion_id"
    t.datetime "created_at"
    t.boolean "visible_to_student", default: false
  end

  create_table "suggestions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "assignment_id"
    t.string "title"
    t.text "description"
    t.string "status"
    t.string "unityID"
    t.string "signup_preference"
  end

  create_table "survey_deployments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "questionnaire_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "last_reminder"
    t.integer "parent_id", default: 0, null: false
    t.integer "global_survey_id"
    t.string "type"
    t.index ["questionnaire_id"], name: "fk_rails_7c62b6ef2b"
  end

  create_table "survey_responses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
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

  create_table "system_settings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
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

  create_table "ta_mappings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "ta_id"
    t.integer "course_id"
    t.index ["course_id"], name: "fk_ta_mappings_course_id"
    t.index ["ta_id"], name: "fk_ta_mappings_ta_id"
  end

  create_table "tag_prompt_deployments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "tag_prompt_id"
    t.integer "assignment_id"
    t.integer "questionnaire_id"
    t.string "question_type"
    t.integer "answer_length_threshold"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_tag_prompt_deployments_on_assignment_id"
    t.index ["questionnaire_id"], name: "index_tag_prompt_deployments_on_questionnaire_id"
    t.index ["tag_prompt_id"], name: "index_tag_prompt_deployments_on_tag_prompt_id"
  end

  create_table "tag_prompts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "prompt"
    t.string "desc"
    t.string "control_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.integer "parent_id"
    t.string "type"
    t.text "comments_for_advertisement"
    t.boolean "advertise_for_partner"
    t.text "submitted_hyperlinks"
    t.integer "directory_num"
    t.integer "grade_for_submission"
    t.text "comment_for_submission"
    t.boolean "make_public", default: false
    t.integer "pair_programming_request", limit: 1
  end

  create_table "teams_users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "team_id"
    t.integer "user_id"
    t.integer "duty_id"
    t.string "pair_programming_status", limit: 1
    t.integer "participant_id"
    t.index ["duty_id"], name: "index_teams_users_on_duty_id"
    t.index ["participant_id"], name: "fk_rails_7192605c92"
    t.index ["team_id"], name: "fk_users_teams"
    t.index ["user_id"], name: "fk_teams_users"
  end

  create_table "track_notifications", id: :integer, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "notification_id", null: false
    t.index ["notification_id"], name: "notification_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "tree_folders", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.string "child_type"
    t.integer "parent_id"
  end

  create_table "user_pastebins", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.integer "user_id"
    t.string "short_form"
    t.text "long_form"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string "username", default: "", null: false
    t.string "crypted_password", limit: 40, default: "", null: false
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
    t.boolean "is_new_user", default: true, null: false
    t.integer "master_permission_granted", limit: 1, default: 0
    t.string "handle"
    t.text "digital_certificate", limit: 16777215
    t.string "persistence_token"
    t.string "timezonepref"
    t.text "public_key", limit: 16777215
    t.boolean "copy_of_emails", default: false
    t.integer "institution_id"
    t.boolean "etc_icons_on_homepage", default: true
    t.integer "locale", default: 0
    t.index ["role_id"], name: "fk_user_role_id"
  end

  create_table "versions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3" do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 16777215
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "wiki_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci" do |t|
    t.string "name", default: "", null: false
  end

  add_foreign_key "answer_tags", "answers"
  add_foreign_key "answer_tags", "tag_prompt_deployments"
  add_foreign_key "answer_tags", "users"
  add_foreign_key "answers", "questions", name: "fk_score_questions"
  add_foreign_key "answers", "responses", name: "fk_score_response"
  add_foreign_key "assignment_badges", "assignments"
  add_foreign_key "assignment_badges", "badges"
  add_foreign_key "assignment_questionnaires", "assignments", name: "fk_aq_assignments_id"
  add_foreign_key "assignment_questionnaires", "duties"
  add_foreign_key "assignment_questionnaires", "questionnaires", name: "fk_aq_questionnaire_id"
  add_foreign_key "assignments", "assignments", column: "sample_assignment_id"
  add_foreign_key "assignments", "late_policies", name: "fk_late_policy_id"
  add_foreign_key "assignments", "users", column: "instructor_id", name: "fk_assignments_instructors"
  add_foreign_key "assignments_questionnaires", "assignments", name: "fk_assignments_questionnaires_assignments"
  add_foreign_key "assignments_questionnaires", "questionnaires", name: "fk_assignments_questionnaires_questionnaires"
  add_foreign_key "automated_metareviews", "responses", name: "fk_automated_metareviews_responses_id"
  add_foreign_key "awarded_badges", "badges"
  add_foreign_key "awarded_badges", "participants"
  add_foreign_key "courses", "users", column: "instructor_id", name: "fk_course_users"
  add_foreign_key "courses_users", "courses", name: "fk_users_courses"
  add_foreign_key "courses_users", "users", name: "fk_courses_users"
  add_foreign_key "due_dates", "deadline_rights", column: "review_allowed_id", name: "fk_due_date_review_allowed"
  add_foreign_key "due_dates", "deadline_rights", column: "review_of_review_allowed_id", name: "fk_due_date_review_of_review_allowed"
  add_foreign_key "due_dates", "deadline_rights", column: "submission_allowed_id", name: "fk_due_date_submission_allowed"
  add_foreign_key "due_dates", "deadline_types", name: "fk_deadline_type_due_date"
  add_foreign_key "duties", "assignments"
  add_foreign_key "invitations", "assignments", name: "fk_invitation_assignments"
  add_foreign_key "invitations", "users", column: "from_id", name: "fk_invitationfrom_users"
  add_foreign_key "invitations", "users", column: "to_id", name: "fk_invitationto_users"
  add_foreign_key "late_policies", "users", column: "instructor_id", name: "fk_instructor_id"
  add_foreign_key "locks", "users"
  add_foreign_key "participants", "duties"
  add_foreign_key "participants", "users", name: "fk_participant_users"
  add_foreign_key "plagiarism_checker_assignment_submissions", "assignments"
  add_foreign_key "plagiarism_checker_comparisons", "plagiarism_checker_assignment_submissions"
  add_foreign_key "question_advices", "questions", name: "fk_question_question_advices"
  add_foreign_key "questions", "questionnaires", name: "fk_question_questionnaires"
  add_foreign_key "resubmission_times", "participants", name: "fk_resubmission_times_participants"
  add_foreign_key "review_bids", "assignments"
  add_foreign_key "review_bids", "participants"
  add_foreign_key "review_bids", "sign_up_topics", column: "signuptopic_id"
  add_foreign_key "review_bids", "users"
  add_foreign_key "review_comment_paste_bins", "review_grades"
  add_foreign_key "review_feedbacks", "assignments", name: "fk_review_feedback_assignments"
  add_foreign_key "review_feedbacks", "reviews", name: "fk_review_feedback_reviews"
  add_foreign_key "review_grades", "participants"
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
  add_foreign_key "sign_up_topics", "assignments", name: "fk_sign_up_topics_assignments"
  add_foreign_key "signed_up_teams", "sign_up_topics", column: "topic_id", name: "fk_signed_up_users_sign_up_topics"
  add_foreign_key "survey_deployments", "questionnaires"
  add_foreign_key "ta_mappings", "courses", name: "fk_ta_mappings_course_id"
  add_foreign_key "ta_mappings", "users", column: "ta_id", name: "fk_ta_mappings_ta_id"
  add_foreign_key "tag_prompt_deployments", "assignments"
  add_foreign_key "tag_prompt_deployments", "questionnaires"
  add_foreign_key "tag_prompt_deployments", "tag_prompts"
  add_foreign_key "teams_users", "duties"
  add_foreign_key "teams_users", "participants"
  add_foreign_key "teams_users", "teams", name: "fk_users_teams"
  add_foreign_key "teams_users", "users", name: "fk_teams_users"
end
