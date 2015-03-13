# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 201150105163040) do

  create_table "assignment_questionnaires", force: :cascade do |t|
    t.integer "assignment_id",        limit: 4
    t.integer "questionnaire_id",     limit: 4
    t.integer "user_id",              limit: 4
    t.integer "notification_limit",   limit: 4, default: 15, null: false
    t.integer "questionnaire_weight", limit: 4, default: 0,  null: false
    t.integer "used_in_round",        limit: 4
  end

  add_index "assignment_questionnaires", ["assignment_id"], name: "fk_aq_assignments_id", using: :btree
  add_index "assignment_questionnaires", ["questionnaire_id"], name: "fk_aq_questionnaire_id", using: :btree
  add_index "assignment_questionnaires", ["user_id"], name: "fk_aq_user_id", using: :btree

  create_table "assignments", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                              limit: 255
    t.string   "directory_path",                    limit: 255
    t.integer  "submitter_count",                   limit: 8,     default: 0,     null: false
    t.integer  "course_id",                         limit: 4,     default: 0
    t.integer  "instructor_id",                     limit: 4,     default: 0
    t.boolean  "private",                           limit: 1,     default: false, null: false
    t.integer  "num_reviews",                       limit: 4,     default: 0,     null: false
    t.integer  "num_review_of_reviews",             limit: 4,     default: 0,     null: false
    t.integer  "num_review_of_reviewers",           limit: 4,     default: 0,     null: false
    t.integer  "review_questionnaire_id",           limit: 4
    t.integer  "review_of_review_questionnaire_id", limit: 4
    t.boolean  "reviews_visible_to_all",            limit: 1
    t.boolean  "team_assignment",                   limit: 1
    t.integer  "wiki_type_id",                      limit: 4
    t.boolean  "require_signup",                    limit: 1
    t.integer  "num_reviewers",                     limit: 8,     default: 0,     null: false
    t.text     "spec_location",                     limit: 65535
    t.integer  "author_feedback_questionnaire_id",  limit: 4
    t.integer  "teammate_review_questionnaire_id",  limit: 4
    t.integer  "max_team_size",                     limit: 4,     default: 0,     null: false
    t.boolean  "staggered_deadline",                limit: 1
    t.boolean  "allow_suggestions",                 limit: 1
    t.integer  "days_between_submissions",          limit: 4
    t.string   "review_assignment_strategy",        limit: 255
    t.integer  "max_reviews_per_submission",        limit: 4
    t.integer  "review_topic_threshold",            limit: 4,     default: 0
    t.boolean  "copy_flag",                         limit: 1,     default: false
    t.integer  "rounds_of_reviews",                 limit: 4,     default: 1
    t.boolean  "microtask",                         limit: 1,     default: false
    t.boolean  "availability_flag",                 limit: 1
    t.boolean  "require_quiz",                      limit: 1
    t.integer  "num_quiz_questions",                limit: 4,     default: 0,     null: false
    t.boolean  "is_coding_assignment",              limit: 1
    t.boolean  "is_intelligent",                    limit: 1
    t.integer  "selfreview_questionnaire_id",       limit: 4
    t.integer  "managerreview_questionnaire_id",    limit: 4
    t.integer  "readerreview_questionnaire_id",     limit: 4
    t.boolean  "calculate_penalty",                 limit: 1,     default: false, null: false
    t.integer  "late_policy_id",                    limit: 4
    t.boolean  "is_penalty_calculated",             limit: 1,     default: false, null: false
    t.integer  "max_bids",                          limit: 4
  end

  add_index "assignments", ["course_id"], name: "fk_assignments_courses", using: :btree
  add_index "assignments", ["instructor_id"], name: "fk_assignments_instructors", using: :btree
  add_index "assignments", ["late_policy_id"], name: "fk_late_policy_id", using: :btree
  add_index "assignments", ["review_of_review_questionnaire_id"], name: "fk_assignments_review_of_review_questionnaires", using: :btree
  add_index "assignments", ["review_questionnaire_id"], name: "fk_assignments_review_questionnaires", using: :btree
  add_index "assignments", ["wiki_type_id"], name: "fk_assignments_wiki_types", using: :btree

  create_table "automated_metareviews", force: :cascade do |t|
    t.float    "relevance",         limit: 24
    t.float    "content_summative", limit: 24
    t.float    "content_problem",   limit: 24
    t.float    "content_advisory",  limit: 24
    t.float    "tone_positive",     limit: 24
    t.float    "tone_negative",     limit: 24
    t.float    "tone_neutral",      limit: 24
    t.integer  "quantity",          limit: 4
    t.integer  "plagiarism",        limit: 4
    t.integer  "version_num",       limit: 4
    t.integer  "response_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "automated_metareviews", ["response_id"], name: "fk_automated_metareviews_responses_id", using: :btree

  create_table "bids", force: :cascade do |t|
    t.integer  "topic_id",   limit: 4
    t.integer  "team_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "priority",   limit: 4
  end

  add_index "bids", ["team_id"], name: "index_bids_on_team_id", using: :btree
  add_index "bids", ["topic_id"], name: "index_bids_on_topic_id", using: :btree

  create_table "bmapping_ratings", force: :cascade do |t|
    t.integer  "bmapping_id", limit: 4, null: false
    t.integer  "user_id",     limit: 4, null: false
    t.integer  "rating",      limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bmappings", force: :cascade do |t|
    t.integer  "bookmark_id",   limit: 4,   null: false
    t.string   "title",         limit: 255
    t.integer  "user_id",       limit: 4,   null: false
    t.string   "description",   limit: 255
    t.datetime "date_created",              null: false
    t.datetime "date_modified",             null: false
  end

  create_table "bmappings_sign_up_topics", id: false, force: :cascade do |t|
    t.integer "sign_up_topic_id", limit: 4, null: false
    t.integer "bmapping_id",      limit: 4, null: false
  end

  create_table "bmappings_tags", force: :cascade do |t|
    t.integer  "tag_id",      limit: 4, null: false
    t.integer  "bmapping_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookmark_rating_rubrics", force: :cascade do |t|
    t.string   "display_text",   limit: 255, null: false
    t.integer  "minimum_rating", limit: 4,   null: false
    t.integer  "maximum_rating", limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookmark_tags", force: :cascade do |t|
    t.string   "tag_name",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.string   "url",                limit: 255, null: false
    t.integer  "discoverer_user_id", limit: 4,   null: false
    t.integer  "user_count",         limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "books", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "calculated_penalties", force: :cascade do |t|
    t.integer "participant_id",   limit: 4
    t.integer "deadline_type_id", limit: 4
    t.integer "penalty_points",   limit: 4
  end

  create_table "comments", force: :cascade do |t|
    t.integer "participant_id", limit: 4,     null: false
    t.boolean "private",        limit: 1,     null: false
    t.text    "comment",        limit: 65535, null: false
  end

  create_table "content_pages", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.string   "name",            limit: 255,   default: "", null: false
    t.integer  "markup_style_id", limit: 4
    t.text     "content",         limit: 65535
    t.integer  "permission_id",   limit: 4,     default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content_cache",   limit: 65535
  end

  add_index "content_pages", ["markup_style_id"], name: "fk_content_page_markup_style_id", using: :btree
  add_index "content_pages", ["permission_id"], name: "fk_content_page_permission_id", using: :btree

  create_table "controller_actions", force: :cascade do |t|
    t.integer "site_controller_id", limit: 4,   default: 0,  null: false
    t.string  "name",               limit: 255, default: "", null: false
    t.integer "permission_id",      limit: 4
    t.string  "url_to_use",         limit: 255
  end

  add_index "controller_actions", ["permission_id"], name: "fk_controller_action_permission_id", using: :btree
  add_index "controller_actions", ["site_controller_id"], name: "fk_controller_action_site_controller_id", using: :btree

  create_table "courses", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "instructor_id",  limit: 4
    t.string   "directory_path", limit: 255
    t.text     "info",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",        limit: 1,     default: false, null: false
  end

  add_index "courses", ["instructor_id"], name: "fk_course_users", using: :btree

  create_table "deadline_rights", force: :cascade do |t|
    t.string "name", limit: 32
  end

  create_table "deadline_types", force: :cascade do |t|
    t.string "name", limit: 32
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue",      limit: 255
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "due_dates", force: :cascade do |t|
    t.datetime "due_at"
    t.integer  "deadline_type_id",            limit: 4
    t.integer  "assignment_id",               limit: 4
    t.integer  "submission_allowed_id",       limit: 4
    t.integer  "review_allowed_id",           limit: 4
    t.integer  "resubmission_allowed_id",     limit: 4
    t.integer  "rereview_allowed_id",         limit: 4
    t.integer  "review_of_review_allowed_id", limit: 4
    t.integer  "round",                       limit: 4
    t.boolean  "flag",                        limit: 1,   default: false
    t.integer  "threshold",                   limit: 4,   default: 1
    t.integer  "delayed_job_id",              limit: 4
    t.integer  "quiz_allowed_id",             limit: 4
    t.string   "deadline_name",               limit: 255
    t.string   "description_url",             limit: 255
  end

  add_index "due_dates", ["assignment_id"], name: "fk_due_dates_assignments", using: :btree
  add_index "due_dates", ["deadline_type_id"], name: "fk_deadline_type_due_date", using: :btree
  add_index "due_dates", ["rereview_allowed_id"], name: "idx_rereview_allowed", using: :btree
  add_index "due_dates", ["resubmission_allowed_id"], name: "idx_resubmission_allowed", using: :btree
  add_index "due_dates", ["review_allowed_id"], name: "idx_review_allowed", using: :btree
  add_index "due_dates", ["review_of_review_allowed_id"], name: "idx_review_of_review_allowed", using: :btree
  add_index "due_dates", ["submission_allowed_id"], name: "idx_submission_allowed", using: :btree

  create_table "institutions", force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "assignment_id", limit: 4
    t.integer "from_id",       limit: 4
    t.integer "to_id",         limit: 4
    t.string  "reply_status",  limit: 1
  end

  add_index "invitations", ["assignment_id"], name: "fk_invitation_assignments", using: :btree
  add_index "invitations", ["from_id"], name: "fk_invitationfrom_users", using: :btree
  add_index "invitations", ["to_id"], name: "fk_invitationto_users", using: :btree

  create_table "join_team_requests", force: :cascade do |t|
    t.integer  "participant_id", limit: 4
    t.integer  "team_id",        limit: 4
    t.text     "comments",       limit: 65535
    t.string   "status",         limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name", limit: 32
  end

  create_table "late_policies", force: :cascade do |t|
    t.float   "penalty_per_unit", limit: 24
    t.integer "max_penalty",      limit: 4,   default: 0, null: false
    t.string  "penalty_unit",     limit: 255,             null: false
    t.integer "times_used",       limit: 4,   default: 0, null: false
    t.integer "instructor_id",    limit: 4,               null: false
    t.string  "policy_name",      limit: 255,             null: false
  end

  add_index "late_policies", ["instructor_id"], name: "fk_instructor_id", using: :btree

  create_table "leaderboards", force: :cascade do |t|
    t.integer "questionnaire_type_id", limit: 4
    t.string  "name",                  limit: 255
    t.string  "qtype",                 limit: 255
  end

  create_table "markup_styles", force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
  end

  create_table "menu_items", force: :cascade do |t|
    t.integer "parent_id",            limit: 4
    t.string  "name",                 limit: 255, default: "", null: false
    t.string  "label",                limit: 255, default: "", null: false
    t.integer "seq",                  limit: 4
    t.integer "controller_action_id", limit: 4
    t.integer "content_page_id",      limit: 4
  end

  add_index "menu_items", ["content_page_id"], name: "fk_menu_item_content_page_id", using: :btree
  add_index "menu_items", ["controller_action_id"], name: "fk_menu_item_controller_action_id", using: :btree
  add_index "menu_items", ["parent_id"], name: "fk_menu_item_parent_id", using: :btree

  create_table "nodes", force: :cascade do |t|
    t.integer "parent_id",      limit: 4
    t.integer "node_object_id", limit: 4
    t.string  "type",           limit: 255
    t.string  "name",           limit: 255
    t.integer "lft",            limit: 4
    t.integer "rgt",            limit: 4
    t.integer "depth",          limit: 4
  end

  create_table "participant_score_views", id: false, force: :cascade do |t|
    t.integer "response_id",        limit: 4,  default: 0, null: false
    t.integer "score",              limit: 4
    t.integer "weight",             limit: 4
    t.string  "questionaire_type",  limit: 64
    t.integer "max_question_score", limit: 4
    t.integer "team_id",            limit: 4,  default: 0, null: false
    t.integer "participant_id",     limit: 4
    t.integer "assignment_id",      limit: 4,  default: 0, null: false
  end

  create_table "participant_team_roles", force: :cascade do |t|
    t.integer  "role_assignment_id", limit: 4
    t.integer  "participant_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participant_team_roles", ["participant_id"], name: "fk_participant_id", using: :btree
  add_index "participant_team_roles", ["role_assignment_id"], name: "fk_role_assignment_id", using: :btree

  create_table "participants", force: :cascade do |t|
    t.boolean  "submit_allowed",       limit: 1,     default: true
    t.boolean  "review_allowed",       limit: 1,     default: true
    t.integer  "user_id",              limit: 4
    t.integer  "parent_id",            limit: 4
    t.integer  "directory_num",        limit: 4
    t.datetime "submitted_at"
    t.boolean  "permission_granted",   limit: 1
    t.integer  "penalty_accumulated",  limit: 8,     default: 0,    null: false
    t.string   "submitted_hyperlinks", limit: 100
    t.float    "grade",                limit: 24
    t.string   "type",                 limit: 255
    t.string   "handle",               limit: 255
    t.integer  "topic_id",             limit: 4
    t.datetime "time_stamp"
    t.text     "digital_signature",    limit: 65535
    t.string   "special_role",         limit: 255
  end

  add_index "participants", ["user_id"], name: "fk_participant_users", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
  end

  create_table "plugin_schema_info", id: false, force: :cascade do |t|
    t.string  "plugin_name", limit: 255
    t.integer "version",     limit: 4
  end

  create_table "question_advices", force: :cascade do |t|
    t.integer "question_id", limit: 4
    t.integer "score",       limit: 4
    t.text    "advice",      limit: 65535
  end

  add_index "question_advices", ["question_id"], name: "fk_question_question_advices", using: :btree

  create_table "question_types", force: :cascade do |t|
    t.string  "q_type",      limit: 255,             null: false
    t.string  "parameters",  limit: 255
    t.integer "question_id", limit: 4,   default: 1, null: false
  end

  add_index "question_types", ["question_id"], name: "fk_question_type_question", using: :btree

  create_table "questionnaires", force: :cascade do |t|
    t.string   "name",                limit: 64
    t.integer  "instructor_id",       limit: 4,     default: 0,     null: false
    t.boolean  "private",             limit: 1,     default: false, null: false
    t.integer  "min_question_score",  limit: 4,     default: 0,     null: false
    t.integer  "max_question_score",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at",                                        null: false
    t.integer  "default_num_choices", limit: 4
    t.string   "type",                limit: 255
    t.string   "display_type",        limit: 255
    t.string   "section",             limit: 255
    t.text     "instruction_loc",     limit: 65535
  end

  create_table "questions", force: :cascade do |t|
    t.text    "txt",              limit: 65535
    t.boolean "true_false",       limit: 1
    t.integer "weight",           limit: 4
    t.integer "questionnaire_id", limit: 4
  end

  add_index "questions", ["questionnaire_id"], name: "fk_question_questionnaires", using: :btree

  create_table "quiz_question_choices", force: :cascade do |t|
    t.integer "question_id", limit: 4
    t.text    "txt",         limit: 65535
    t.boolean "iscorrect",   limit: 1,     default: false
  end

  create_table "response_maps", force: :cascade do |t|
    t.integer  "reviewed_object_id",    limit: 4,                   null: false
    t.integer  "reviewer_id",           limit: 4,                   null: false
    t.integer  "reviewee_id",           limit: 4,                   null: false
    t.string   "type",                  limit: 255,                 null: false
    t.boolean  "notification_accepted", limit: 1,   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "round",                 limit: 4
  end

  add_index "response_maps", ["reviewed_object_id"], name: "index_response_maps_on_reviewed_object_id", using: :btree
  add_index "response_maps", ["reviewee_id"], name: "index_response_maps_on_reviewee_id", using: :btree
  add_index "response_maps", ["reviewer_id"], name: "index_response_maps_on_reviewer_id", using: :btree

  create_table "responses", force: :cascade do |t|
    t.integer  "map_id",             limit: 4,   null: false
    t.string   "additional_comment", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "responses", ["map_id"], name: "index_responses_on_map_id", using: :btree

  create_table "resubmission_times", force: :cascade do |t|
    t.integer  "participant_id", limit: 4
    t.datetime "resubmitted_at"
  end

  add_index "resubmission_times", ["participant_id"], name: "fk_resubmission_times_participants", using: :btree

  create_table "review_comments", force: :cascade do |t|
    t.integer  "review_file_id",          limit: 4
    t.text     "comment_content",         limit: 65535
    t.integer  "reviewer_participant_id", limit: 4
    t.integer  "file_offset",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "initial_line_number",     limit: 4
    t.integer  "last_line_number",        limit: 4
  end

  create_table "review_files", force: :cascade do |t|
    t.string   "filepath",              limit: 255
    t.integer  "author_participant_id", limit: 4
    t.integer  "version_number",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",            limit: 255,   default: "", null: false
    t.integer  "parent_id",       limit: 4
    t.string   "description",     limit: 255,   default: "", null: false
    t.integer  "default_page_id", limit: 4
    t.text     "cache",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["default_page_id"], name: "fk_role_default_page_id", using: :btree
  add_index "roles", ["parent_id"], name: "fk_role_parent_id", using: :btree

  create_table "roles_permissions", force: :cascade do |t|
    t.integer "role_id",       limit: 4, default: 0, null: false
    t.integer "permission_id", limit: 4, default: 0, null: false
  end

  add_index "roles_permissions", ["permission_id"], name: "fk_roles_permission_permission_id", using: :btree
  add_index "roles_permissions", ["role_id"], name: "fk_roles_permission_role_id", using: :btree

  create_table "score_caches", force: :cascade do |t|
    t.integer "reviewee_id", limit: 4,   default: 0,   null: false
    t.float   "score",       limit: 24,  default: 0.0, null: false
    t.string  "range",       limit: 255, default: ""
    t.string  "object_type", limit: 255,               null: false
  end

  add_index "score_caches", ["reviewee_id"], name: "index_score_caches_on_reviewee_id", using: :btree

  create_table "score_views", id: false, force: :cascade do |t|
    t.integer  "question_weight",        limit: 4
    t.integer  "q_id",                   limit: 4,     default: 0
    t.string   "q_type",                 limit: 255
    t.string   "q_parameters",           limit: 255
    t.integer  "q_question_id",          limit: 4,     default: 1
    t.integer  "q1_id",                  limit: 4,     default: 0
    t.string   "q1_name",                limit: 64
    t.integer  "q1_instructor_id",       limit: 4,     default: 0
    t.boolean  "q1_private",             limit: 1,     default: false
    t.integer  "q1_min_question_score",  limit: 4,     default: 0
    t.integer  "q1_max_question_score",  limit: 4
    t.datetime "q1_created_at"
    t.datetime "q1_updated_at"
    t.integer  "q1_default_num_choices", limit: 4
    t.string   "q1_type",                limit: 255
    t.string   "q1_display_type",        limit: 255
    t.string   "q1_section",             limit: 255
    t.text     "q1_instruction_loc",     limit: 65535
    t.integer  "ques_id",                limit: 4,     default: 0,     null: false
    t.integer  "ques_questionnaire_id",  limit: 4
    t.integer  "s_id",                   limit: 4,     default: 0
    t.integer  "s_question_id",          limit: 4
    t.integer  "s_score",                limit: 4
    t.text     "s_comments",             limit: 65535
    t.integer  "s_response_id",          limit: 4
  end

  create_table "scores", force: :cascade do |t|
    t.integer "question_id", limit: 4,     null: false
    t.integer "score",       limit: 4
    t.text    "comments",    limit: 65535
    t.integer "response_id", limit: 4
  end

  add_index "scores", ["question_id"], name: "fk_score_questions", using: :btree
  add_index "scores", ["response_id"], name: "fk_score_response", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,      null: false
    t.text     "data",       limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sign_up_topics", force: :cascade do |t|
    t.text    "topic_name",                limit: 65535,             null: false
    t.integer "assignment_id",             limit: 4,                 null: false
    t.integer "max_choosers",              limit: 4,                 null: false
    t.text    "category",                  limit: 65535
    t.string  "topic_identifier",          limit: 10
    t.integer "micropayment",              limit: 4,     default: 0
    t.integer "bookmark_rating_rubric_id", limit: 4
  end

  add_index "sign_up_topics", ["assignment_id"], name: "fk_sign_up_categories_sign_up_topics", using: :btree
  add_index "sign_up_topics", ["assignment_id"], name: "index_sign_up_topics_on_assignment_id", using: :btree

  create_table "signed_up_users", force: :cascade do |t|
    t.integer "topic_id",                   limit: 4, null: false
    t.integer "creator_id",                 limit: 4, null: false
    t.boolean "is_waitlisted",              limit: 1, null: false
    t.integer "preference_priority_number", limit: 4
  end

  add_index "signed_up_users", ["topic_id"], name: "fk_signed_up_users_sign_up_topics", using: :btree

  create_table "site_controllers", force: :cascade do |t|
    t.string  "name",          limit: 255, default: "", null: false
    t.integer "permission_id", limit: 4,   default: 0,  null: false
    t.integer "builtin",       limit: 4,   default: 0
  end

  add_index "site_controllers", ["permission_id"], name: "fk_site_controller_permission_id", using: :btree

  create_table "suggestion_comments", force: :cascade do |t|
    t.text     "comments",      limit: 65535
    t.string   "commenter",     limit: 255
    t.string   "vote",          limit: 255
    t.integer  "suggestion_id", limit: 4
    t.datetime "created_at"
  end

  create_table "suggestions", force: :cascade do |t|
    t.integer "assignment_id",     limit: 4
    t.string  "title",             limit: 255
    t.string  "description",       limit: 750
    t.string  "status",            limit: 255
    t.string  "unityID",           limit: 255
    t.string  "signup_preference", limit: 255
  end

  create_table "survey_deployments", force: :cascade do |t|
    t.integer  "course_evaluation_id", limit: 4
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "num_of_students",      limit: 4
    t.datetime "last_reminder"
  end

  create_table "survey_participants", force: :cascade do |t|
    t.integer "user_id",              limit: 4
    t.integer "survey_deployment_id", limit: 4
  end

  create_table "survey_responses", force: :cascade do |t|
    t.integer "score",                limit: 8
    t.text    "comments",             limit: 65535
    t.integer "assignment_id",        limit: 8,     default: 0, null: false
    t.integer "question_id",          limit: 8,     default: 0, null: false
    t.integer "survey_id",            limit: 8,     default: 0, null: false
    t.string  "email",                limit: 255
    t.integer "survey_deployment_id", limit: 4
  end

  add_index "survey_responses", ["assignment_id"], name: "fk_survey_assignments", using: :btree
  add_index "survey_responses", ["question_id"], name: "fk_survey_questions", using: :btree
  add_index "survey_responses", ["survey_id"], name: "fk_survey_questionnaires", using: :btree

  create_table "system_settings", force: :cascade do |t|
    t.string  "site_name",                 limit: 255, default: "", null: false
    t.string  "site_subtitle",             limit: 255
    t.string  "footer_message",            limit: 255, default: ""
    t.integer "public_role_id",            limit: 4,   default: 0,  null: false
    t.integer "session_timeout",           limit: 4,   default: 0,  null: false
    t.integer "default_markup_style_id",   limit: 4,   default: 0
    t.integer "site_default_page_id",      limit: 4,   default: 0,  null: false
    t.integer "not_found_page_id",         limit: 4,   default: 0,  null: false
    t.integer "permission_denied_page_id", limit: 4,   default: 0,  null: false
    t.integer "session_expired_page_id",   limit: 4,   default: 0,  null: false
    t.integer "menu_depth",                limit: 4,   default: 0,  null: false
  end

  add_index "system_settings", ["not_found_page_id"], name: "fk_system_settings_not_found_page_id", using: :btree
  add_index "system_settings", ["permission_denied_page_id"], name: "fk_system_settings_permission_denied_page_id", using: :btree
  add_index "system_settings", ["public_role_id"], name: "fk_system_settings_public_role_id", using: :btree
  add_index "system_settings", ["session_expired_page_id"], name: "fk_system_settings_session_expired_page_id", using: :btree
  add_index "system_settings", ["site_default_page_id"], name: "fk_system_settings_site_default_page_id", using: :btree

  create_table "ta_mappings", force: :cascade do |t|
    t.integer "ta_id",     limit: 4
    t.integer "course_id", limit: 4
  end

  add_index "ta_mappings", ["course_id"], name: "fk_ta_mappings_course_id", using: :btree
  add_index "ta_mappings", ["ta_id"], name: "fk_ta_mappings_ta_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string "tagname", limit: 255, null: false
  end

  create_table "team_role_questionnaire", force: :cascade do |t|
    t.integer  "team_roles_id",    limit: 4
    t.integer  "questionnaire_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "team_role_questionnaire", ["questionnaire_id"], name: "fk_questionnaire_id", using: :btree
  add_index "team_role_questionnaire", ["team_roles_id"], name: "fk_team_roles_id", using: :btree

  create_table "team_roles", force: :cascade do |t|
    t.string  "role_names",       limit: 255
    t.integer "questionnaire_id", limit: 4
  end

  add_index "team_roles", ["questionnaire_id"], name: "fk_team_roles_questionnaire", using: :btree

  create_table "team_rolesets", force: :cascade do |t|
    t.string "roleset_name", limit: 255
  end

  create_table "team_rolesets_maps", force: :cascade do |t|
    t.integer  "team_rolesets_id", limit: 4
    t.integer  "team_role_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "team_rolesets_maps", ["team_role_id"], name: "fk_team_role_id", using: :btree
  add_index "team_rolesets_maps", ["team_rolesets_id"], name: "fk_team_rolesets_id", using: :btree

  create_table "teamrole_assignment", force: :cascade do |t|
    t.integer "team_roleset_id", limit: 4
    t.integer "assignment_id",   limit: 4
  end

  add_index "teamrole_assignment", ["assignment_id"], name: "fk_teamrole_assignment_assignments", using: :btree
  add_index "teamrole_assignment", ["team_roleset_id"], name: "fk_teamrole_assignment_team_rolesets", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string  "name",                       limit: 255
    t.integer "parent_id",                  limit: 4,     default: 0, null: false
    t.string  "type",                       limit: 255
    t.text    "comments_for_advertisement", limit: 65535
    t.boolean "advertise_for_partner",      limit: 1
  end

  create_table "teams_users", force: :cascade do |t|
    t.integer "team_id", limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "teams_users", ["team_id"], name: "fk_users_teams", using: :btree
  add_index "teams_users", ["team_id"], name: "index_teams_users_on_team_id", using: :btree
  add_index "teams_users", ["user_id"], name: "fk_teams_users", using: :btree
  add_index "teams_users", ["user_id"], name: "index_teams_users_on_user_id", using: :btree

  create_table "topic_deadlines", force: :cascade do |t|
    t.datetime "due_at"
    t.integer  "deadline_type_id",            limit: 4
    t.integer  "topic_id",                    limit: 4
    t.integer  "late_policy_id",              limit: 4
    t.integer  "submission_allowed_id",       limit: 4
    t.integer  "review_allowed_id",           limit: 4
    t.integer  "resubmission_allowed_id",     limit: 4
    t.integer  "rereview_allowed_id",         limit: 4
    t.integer  "review_of_review_allowed_id", limit: 4
    t.integer  "round",                       limit: 4
  end

  add_index "topic_deadlines", ["rereview_allowed_id"], name: "idx_rereview_allowed", using: :btree
  add_index "topic_deadlines", ["resubmission_allowed_id"], name: "idx_resubmission_allowed", using: :btree
  add_index "topic_deadlines", ["review_allowed_id"], name: "idx_review_allowed", using: :btree
  add_index "topic_deadlines", ["review_of_review_allowed_id"], name: "idx_review_of_review_allowed", using: :btree
  add_index "topic_deadlines", ["submission_allowed_id"], name: "idx_submission_allowed", using: :btree
  add_index "topic_deadlines", ["topic_id"], name: "fk_topic_deadlines_topics", using: :btree

  create_table "topic_dependencies", force: :cascade do |t|
    t.integer "topic_id",     limit: 4,   null: false
    t.string  "dependent_on", limit: 255, null: false
  end

  create_table "tree_folders", force: :cascade do |t|
    t.string  "name",       limit: 255
    t.string  "child_type", limit: 255
    t.integer "parent_id",  limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string  "name",                      limit: 255,   default: "",    null: false
    t.string  "crypted_password",          limit: 40,    default: "",    null: false
    t.integer "role_id",                   limit: 4,     default: 0,     null: false
    t.string  "password_salt",             limit: 255
    t.string  "fullname",                  limit: 255
    t.string  "email",                     limit: 255
    t.integer "parent_id",                 limit: 4
    t.boolean "private_by_default",        limit: 1,     default: false
    t.string  "mru_directory_path",        limit: 128
    t.boolean "email_on_review",           limit: 1
    t.boolean "email_on_submission",       limit: 1
    t.boolean "email_on_review_of_review", limit: 1
    t.boolean "is_new_user",               limit: 1,     default: true
    t.boolean "master_permission_granted", limit: 1
    t.string  "handle",                    limit: 255
    t.boolean "leaderboard_privacy",       limit: 1,     default: false
    t.boolean "copy_of_emails",            limit: 1,     default: false
    t.text    "digital_certificate",       limit: 65535
    t.string  "persistence_token",         limit: 255
    t.string  "timezonepref",              limit: 255
    t.text    "public_key",                limit: 65535
  end

  add_index "users", ["role_id"], name: "fk_user_role_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,   null: false
    t.integer  "item_id",    limit: 4,     null: false
    t.string   "event",      limit: 255,   null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 65535
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "wiki_types", force: :cascade do |t|
    t.string "name", limit: 255, default: "", null: false
  end

  add_foreign_key "assignment_questionnaires", "assignments", name: "fk_aq_assignments_id"
  add_foreign_key "assignment_questionnaires", "questionnaires", name: "fk_aq_questionnaire_id"
  add_foreign_key "assignments", "late_policies", name: "fk_late_policy_id"
  add_foreign_key "assignments", "questionnaires", column: "review_of_review_questionnaire_id", name: "fk_assignments_review_of_review_questionnaires"
  add_foreign_key "assignments", "questionnaires", column: "review_questionnaire_id", name: "fk_assignments_review_questionnaires"
  add_foreign_key "assignments", "users", column: "instructor_id", name: "fk_assignments_instructors"
  add_foreign_key "assignments", "wiki_types", name: "fk_assignments_wiki_types"
  add_foreign_key "automated_metareviews", "responses", name: "fk_automated_metareviews_responses_id"
  add_foreign_key "courses", "users", column: "instructor_id", name: "fk_course_users"
  add_foreign_key "due_dates", "assignments", name: "fk_due_dates_assignments"
  add_foreign_key "due_dates", "deadline_types", name: "fk_deadline_type_due_date"
  add_foreign_key "invitations", "assignments", name: "fk_invitation_assignments"
  add_foreign_key "invitations", "users", column: "from_id", name: "fk_invitationfrom_users"
  add_foreign_key "invitations", "users", column: "to_id", name: "fk_invitationto_users"
  add_foreign_key "late_policies", "users", column: "instructor_id", name: "fk_instructor_id"
  add_foreign_key "participant_team_roles", "participants", name: "fk_participant_id"
  add_foreign_key "participant_team_roles", "teamrole_assignment", column: "role_assignment_id", name: "fk_role_assignment_id"
  add_foreign_key "participants", "users", name: "fk_participant_users"
  add_foreign_key "question_advices", "questions", name: "fk_question_question_advices"
  add_foreign_key "question_types", "questions", name: "fk_question_type_question"
  add_foreign_key "questions", "questionnaires", name: "fk_question_questionnaires"
  add_foreign_key "responses", "response_maps", column: "map_id", name: "fk_response_response_map"
  add_foreign_key "resubmission_times", "participants", name: "fk_resubmission_times_participants"
  add_foreign_key "scores", "questions", name: "fk_score_questions"
  add_foreign_key "scores", "responses", name: "fk_score_response"
  add_foreign_key "sign_up_topics", "assignments", name: "fk_sign_up_topics_assignments"
  add_foreign_key "signed_up_users", "sign_up_topics", column: "topic_id", name: "fk_signed_up_users_sign_up_topics"
  add_foreign_key "ta_mappings", "courses", name: "fk_ta_mappings_course_id"
  add_foreign_key "ta_mappings", "users", column: "ta_id", name: "fk_ta_mappings_ta_id"
  add_foreign_key "team_role_questionnaire", "questionnaires", name: "fk_questionnaire_id"
  add_foreign_key "team_role_questionnaire", "team_roles", column: "team_roles_id", name: "fk_team_roles_id"
  add_foreign_key "team_roles", "questionnaires", name: "fk_team_roles_questionnaire"
  add_foreign_key "team_rolesets_maps", "team_roles", name: "fk_team_role_id"
  add_foreign_key "team_rolesets_maps", "team_rolesets", column: "team_rolesets_id", name: "fk_team_rolesets_id"
  add_foreign_key "teamrole_assignment", "assignments", name: "fk_teamrole_assignment_assignments"
  add_foreign_key "teamrole_assignment", "team_rolesets", name: "fk_teamrole_assignment_team_rolesets"
  add_foreign_key "teams_users", "teams", name: "fk_users_teams"
  add_foreign_key "teams_users", "users", name: "fk_teams_users"
  add_foreign_key "topic_deadlines", "sign_up_topics", column: "topic_id", name: "fk_topic_deadlines_topics"
end
