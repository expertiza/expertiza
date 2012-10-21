# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121018001330) do

  create_table "assignment_questionnaires", :force => true do |t|
    t.integer "assignment_id"
    t.integer "questionnaire_id"
    t.integer "user_id"
    t.integer "notification_limit",   :default => 15, :null => false
    t.integer "questionnaire_weight", :default => 0,  :null => false
  end

  add_index "assignment_questionnaires", ["assignment_id"], :name => "fk_aq_assignments_id"
  add_index "assignment_questionnaires", ["questionnaire_id"], :name => "fk_aq_questionnaire_id"
  add_index "assignment_questionnaires", ["user_id"], :name => "fk_aq_user_id"

  create_table "assignments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "directory_path"
    t.integer  "submitter_count",                   :default => 0,     :null => false
    t.integer  "course_id",                         :default => 0
    t.integer  "instructor_id",                     :default => 0
    t.boolean  "private",                           :default => false, :null => false
    t.integer  "num_reviews",                       :default => 0,     :null => false
    t.integer  "num_review_of_reviews",             :default => 0,     :null => false
    t.integer  "num_review_of_reviewers",           :default => 0,     :null => false
    t.integer  "review_questionnaire_id"
    t.integer  "review_of_review_questionnaire_id"
    t.boolean  "reviews_visible_to_all"
    t.boolean  "team_assignment"
    t.integer  "wiki_type_id"
    t.boolean  "require_signup"
    t.integer  "num_reviewers",                     :default => 0,     :null => false
    t.text     "spec_location"
    t.integer  "author_feedback_questionnaire_id"
    t.integer  "teammate_review_questionnaire_id"
    t.integer  "team_count",                        :default => 0,     :null => false
    t.boolean  "staggered_deadline"
    t.boolean  "allow_suggestions"
    t.integer  "days_between_submissions"
    t.string   "review_assignment_strategy"
    t.integer  "max_reviews_per_submission"
    t.integer  "review_topic_threshold",            :default => 0
    t.boolean  "availability_flag"
  end

  add_index "assignments", ["course_id"], :name => "fk_assignments_courses"
  add_index "assignments", ["instructor_id"], :name => "fk_assignments_instructors"
  add_index "assignments", ["review_of_review_questionnaire_id"], :name => "fk_assignments_review_of_review_questionnaires"
  add_index "assignments", ["review_questionnaire_id"], :name => "fk_assignments_review_questionnaires"
  add_index "assignments", ["wiki_type_id"], :name => "fk_assignments_wiki_types"

  create_table "comments", :force => true do |t|
    t.integer "participant_id", :null => false
    t.boolean "private",        :null => false
    t.text    "comment",        :null => false
  end

  create_table "content_pages", :force => true do |t|
    t.string   "title"
    t.string   "name",            :default => "", :null => false
    t.integer  "markup_style_id"
    t.text     "content"
    t.integer  "permission_id",   :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content_cache"
  end

  add_index "content_pages", ["markup_style_id"], :name => "fk_content_page_markup_style_id"
  add_index "content_pages", ["permission_id"], :name => "fk_content_page_permission_id"

  create_table "controller_actions", :force => true do |t|
    t.integer "site_controller_id", :default => 0,  :null => false
    t.string  "name",               :default => "", :null => false
    t.integer "permission_id"
    t.string  "url_to_use"
  end

  add_index "controller_actions", ["permission_id"], :name => "fk_controller_action_permission_id"
  add_index "controller_actions", ["site_controller_id"], :name => "fk_controller_action_site_controller_id"

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.integer  "instructor_id"
    t.string   "directory_path"
    t.text     "info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",        :default => false, :null => false
  end

  add_index "courses", ["instructor_id"], :name => "fk_course_users"

  create_table "deadline_rights", :force => true do |t|
    t.string "name", :limit => 32
  end

  create_table "deadline_types", :force => true do |t|
    t.string "name", :limit => 32
  end

  create_table "due_dates", :force => true do |t|
    t.datetime "due_at"
    t.integer  "deadline_type_id"
    t.integer  "assignment_id"
    t.integer  "late_policy_id"
    t.integer  "submission_allowed_id"
    t.integer  "review_allowed_id"
    t.integer  "resubmission_allowed_id"
    t.integer  "rereview_allowed_id"
    t.integer  "review_of_review_allowed_id"
    t.integer  "round"
    t.boolean  "flag",                        :default => false
    t.integer  "threshold",                   :default => 1
  end

  add_index "due_dates", ["assignment_id"], :name => "fk_due_dates_assignments"
  add_index "due_dates", ["deadline_type_id"], :name => "fk_deadline_type_due_date"
  add_index "due_dates", ["late_policy_id"], :name => "fk_due_date_late_policies"
  add_index "due_dates", ["rereview_allowed_id"], :name => "idx_rereview_allowed"
  add_index "due_dates", ["resubmission_allowed_id"], :name => "idx_resubmission_allowed"
  add_index "due_dates", ["review_allowed_id"], :name => "idx_review_allowed"
  add_index "due_dates", ["review_of_review_allowed_id"], :name => "idx_review_of_review_allowed"
  add_index "due_dates", ["submission_allowed_id"], :name => "idx_submission_allowed"

  create_table "institutions", :force => true do |t|
    t.string "name", :default => "", :null => false
  end

  create_table "invitations", :force => true do |t|
    t.integer "assignment_id"
    t.integer "from_id"
    t.integer "to_id"
    t.string  "reply_status",  :limit => 1
  end

  add_index "invitations", ["assignment_id"], :name => "fk_invitation_assignments"
  add_index "invitations", ["from_id"], :name => "fk_invitationfrom_users"
  add_index "invitations", ["to_id"], :name => "fk_invitationto_users"

  create_table "join_team_requests", :force => true do |t|
    t.integer  "participant_id"
    t.integer  "team_id"
    t.text     "comments"
    t.string   "status",         :limit => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", :force => true do |t|
    t.string "name", :limit => 32
  end

  create_table "late_policies", :force => true do |t|
    t.integer "penalty_period_in_minutes"
    t.integer "penalty_per_unit"
    t.boolean "expressed_as_percentage"
    t.integer "max_penalty",               :default => 0, :null => false
  end

  add_index "late_policies", ["penalty_period_in_minutes"], :name => "penalty_period_length_unit"

  create_table "leaderboards", :force => true do |t|
    t.integer "questionnaire_type_id"
    t.string  "name"
    t.string  "qtype"
  end

  create_table "markup_styles", :force => true do |t|
    t.string "name", :default => "", :null => false
  end

  create_table "menu_items", :force => true do |t|
    t.integer "parent_id"
    t.string  "name",                 :default => "", :null => false
    t.string  "label",                :default => "", :null => false
    t.integer "seq"
    t.integer "controller_action_id"
    t.integer "content_page_id"
  end

  add_index "menu_items", ["content_page_id"], :name => "fk_menu_item_content_page_id"
  add_index "menu_items", ["controller_action_id"], :name => "fk_menu_item_controller_action_id"
  add_index "menu_items", ["parent_id"], :name => "fk_menu_item_parent_id"

  create_table "nodes", :force => true do |t|
    t.integer "parent_id"
    t.integer "node_object_id"
    t.string  "type"
  end

  create_table "participants", :force => true do |t|
    t.boolean  "submit_allowed",                      :default => true
    t.boolean  "review_allowed",                      :default => true
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "directory_num"
    t.datetime "submitted_at"
    t.boolean  "permission_granted"
    t.integer  "penalty_accumulated",                 :default => 0,    :null => false
    t.string   "submitted_hyperlinks", :limit => 500
    t.float    "grade"
    t.string   "type"
    t.string   "handle"
    t.integer  "topic_id"
    t.datetime "time_stamp"
    t.text     "digital_signature"
  end

  add_index "participants", ["user_id"], :name => "fk_participant_users"

  create_table "permissions", :force => true do |t|
    t.string "name", :default => "", :null => false
  end

  create_table "plugin_schema_info", :id => false, :force => true do |t|
    t.string  "plugin_name"
    t.integer "version"
  end

  create_table "question_advices", :force => true do |t|
    t.integer "question_id"
    t.integer "score"
    t.text    "advice"
  end

  add_index "question_advices", ["question_id"], :name => "fk_question_question_advices"

  create_table "question_types", :force => true do |t|
    t.string  "q_type",                     :null => false
    t.string  "parameters"
    t.integer "question_id", :default => 1, :null => false
  end

  add_index "question_types", ["question_id"], :name => "fk_question_type_question"

  create_table "questionnaires", :force => true do |t|
    t.string   "name",                :limit => 64
    t.integer  "instructor_id",                     :default => 0,     :null => false
    t.boolean  "private",                           :default => false, :null => false
    t.integer  "min_question_score",                :default => 0,     :null => false
    t.integer  "max_question_score"
    t.datetime "created_at"
    t.datetime "updated_at",                                           :null => false
    t.integer  "default_num_choices"
    t.string   "type"
    t.string   "display_type"
    t.string   "section"
    t.text     "instruction_loc"
  end

  create_table "questions", :force => true do |t|
    t.text    "txt"
    t.boolean "true_false"
    t.integer "weight"
    t.integer "questionnaire_id"
  end

  add_index "questions", ["questionnaire_id"], :name => "fk_question_questionnaires"

  create_table "response_maps", :force => true do |t|
    t.integer "reviewed_object_id",                       :null => false
    t.integer "reviewer_id",                              :null => false
    t.integer "reviewee_id",                              :null => false
    t.string  "type",                                     :null => false
    t.boolean "notification_accepted", :default => false
  end

  add_index "response_maps", ["reviewer_id"], :name => "fk_response_map_reviewer"

  create_table "responses", :force => true do |t|
    t.integer  "map_id",             :null => false
    t.string   "additional_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "responses", ["map_id"], :name => "fk_response_response_map"

  create_table "resubmission_times", :force => true do |t|
    t.integer  "participant_id"
    t.datetime "resubmitted_at"
  end

  add_index "resubmission_times", ["participant_id"], :name => "fk_resubmission_times_participants"

  create_table "review_comments", :force => true do |t|
    t.integer  "review_file_id"
    t.text     "comment_content"
    t.integer  "reviewer_participant_id"
    t.integer  "file_offset"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "review_files", :force => true do |t|
    t.string   "filepath"
    t.integer  "author_participant_id"
    t.integer  "version_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",            :default => "", :null => false
    t.integer  "parent_id"
    t.string   "description",     :default => "", :null => false
    t.integer  "default_page_id"
    t.text     "cache"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["default_page_id"], :name => "fk_role_default_page_id"
  add_index "roles", ["parent_id"], :name => "fk_role_parent_id"

  create_table "roles_permissions", :force => true do |t|
    t.integer "role_id",       :default => 0, :null => false
    t.integer "permission_id", :default => 0, :null => false
  end

  add_index "roles_permissions", ["permission_id"], :name => "fk_roles_permission_permission_id"
  add_index "roles_permissions", ["role_id"], :name => "fk_roles_permission_role_id"

  create_table "score_caches", :force => true do |t|
    t.integer "reviewee_id", :default => 0,   :null => false
    t.float   "score",       :default => 0.0, :null => false
    t.string  "range",       :default => ""
    t.string  "object_type",                  :null => false
  end

  create_table "scores", :force => true do |t|
    t.integer "question_id", :null => false
    t.integer "score"
    t.text    "comments"
    t.integer "response_id"
  end

  add_index "scores", ["question_id"], :name => "fk_score_questions"
  add_index "scores", ["response_id"], :name => "fk_score_response"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sign_up_topics", :force => true do |t|
    t.text    "topic_name",                     :null => false
    t.integer "assignment_id",                  :null => false
    t.integer "max_choosers",                   :null => false
    t.text    "category"
    t.string  "topic_identifier", :limit => 10
  end

  add_index "sign_up_topics", ["assignment_id"], :name => "fk_sign_up_categories_sign_up_topics"

  create_table "signed_up_users", :force => true do |t|
    t.integer "topic_id",                   :null => false
    t.integer "creator_id",                 :null => false
    t.boolean "is_waitlisted",              :null => false
    t.integer "preference_priority_number"
  end

  add_index "signed_up_users", ["topic_id"], :name => "fk_signed_up_users_sign_up_topics"

  create_table "site_controllers", :force => true do |t|
    t.string  "name",          :default => "", :null => false
    t.integer "permission_id", :default => 0,  :null => false
    t.integer "builtin",       :default => 0
  end

  add_index "site_controllers", ["permission_id"], :name => "fk_site_controller_permission_id"

  create_table "suggestion_comments", :force => true do |t|
    t.text     "comments"
    t.string   "commenter"
    t.string   "vote"
    t.integer  "suggestion_id"
    t.datetime "created_at"
  end

  create_table "suggestions", :force => true do |t|
    t.integer "assignment_id"
    t.string  "title"
    t.string  "description",       :limit => 750
    t.string  "status"
    t.string  "unityID"
    t.string  "signup_preference"
  end

  create_table "survey_deployments", :force => true do |t|
    t.integer  "course_evaluation_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "num_of_students"
    t.datetime "last_reminder"
  end

  create_table "survey_participants", :force => true do |t|
    t.integer "user_id"
    t.integer "survey_deployment_id"
  end

  create_table "survey_responses", :force => true do |t|
    t.integer "score"
    t.text    "comments"
    t.integer "assignment_id",        :default => 0, :null => false
    t.integer "question_id",          :default => 0, :null => false
    t.integer "survey_id",            :default => 0, :null => false
    t.string  "email"
    t.integer "survey_deployment_id"
  end

  add_index "survey_responses", ["assignment_id"], :name => "fk_survey_assignments"
  add_index "survey_responses", ["question_id"], :name => "fk_survey_questions"
  add_index "survey_responses", ["survey_id"], :name => "fk_survey_questionnaires"

  create_table "system_settings", :force => true do |t|
    t.string  "site_name",                 :default => "", :null => false
    t.string  "site_subtitle"
    t.string  "footer_message",            :default => ""
    t.integer "public_role_id",            :default => 0,  :null => false
    t.integer "session_timeout",           :default => 0,  :null => false
    t.integer "default_markup_style_id",   :default => 0
    t.integer "site_default_page_id",      :default => 0,  :null => false
    t.integer "not_found_page_id",         :default => 0,  :null => false
    t.integer "permission_denied_page_id", :default => 0,  :null => false
    t.integer "session_expired_page_id",   :default => 0,  :null => false
    t.integer "menu_depth",                :default => 0,  :null => false
  end

  add_index "system_settings", ["not_found_page_id"], :name => "fk_system_settings_not_found_page_id"
  add_index "system_settings", ["permission_denied_page_id"], :name => "fk_system_settings_permission_denied_page_id"
  add_index "system_settings", ["public_role_id"], :name => "fk_system_settings_public_role_id"
  add_index "system_settings", ["session_expired_page_id"], :name => "fk_system_settings_session_expired_page_id"
  add_index "system_settings", ["site_default_page_id"], :name => "fk_system_settings_site_default_page_id"

  create_table "ta_mappings", :force => true do |t|
    t.integer "ta_id"
    t.integer "course_id"
  end

  add_index "ta_mappings", ["course_id"], :name => "fk_ta_mappings_course_id"
  add_index "ta_mappings", ["ta_id"], :name => "fk_ta_mappings_ta_id"

  create_table "teams", :force => true do |t|
    t.string  "name"
    t.integer "parent_id",                  :default => 0, :null => false
    t.string  "type"
    t.text    "comments_for_advertisement"
    t.boolean "advertise_for_partner"
  end

  create_table "teams_participants", :force => true do |t|
    t.integer "team_id"
    t.integer "user_id"
  end

  add_index "teams_participants", ["team_id"], :name => "fk_users_teams"
  add_index "teams_participants", ["user_id"], :name => "fk_teams_users"

  create_table "topic_deadlines", :force => true do |t|
    t.datetime "due_at"
    t.integer  "deadline_type_id"
    t.integer  "topic_id"
    t.integer  "late_policy_id"
    t.integer  "submission_allowed_id"
    t.integer  "review_allowed_id"
    t.integer  "resubmission_allowed_id"
    t.integer  "rereview_allowed_id"
    t.integer  "review_of_review_allowed_id"
    t.integer  "round"
  end

  add_index "topic_deadlines", ["rereview_allowed_id"], :name => "idx_rereview_allowed"
  add_index "topic_deadlines", ["resubmission_allowed_id"], :name => "idx_resubmission_allowed"
  add_index "topic_deadlines", ["review_allowed_id"], :name => "idx_review_allowed"
  add_index "topic_deadlines", ["review_of_review_allowed_id"], :name => "idx_review_of_review_allowed"
  add_index "topic_deadlines", ["submission_allowed_id"], :name => "idx_submission_allowed"
  add_index "topic_deadlines", ["topic_id"], :name => "fk_topic_deadlines_topics"

  create_table "topic_dependencies", :force => true do |t|
    t.integer "topic_id",     :null => false
    t.string  "dependent_on", :null => false
  end

  create_table "tree_folders", :force => true do |t|
    t.string  "name"
    t.string  "child_type"
    t.integer "parent_id"
  end

  create_table "users", :force => true do |t|
    t.string  "name",                                     :default => "",    :null => false
    t.string  "password",                  :limit => 40,  :default => "",    :null => false
    t.integer "role_id",                                  :default => 0,     :null => false
    t.string  "password_salt"
    t.string  "fullname"
    t.string  "email"
    t.integer "parent_id"
    t.boolean "private_by_default",                       :default => false
    t.string  "mru_directory_path",        :limit => 128
    t.boolean "email_on_review"
    t.boolean "email_on_submission"
    t.boolean "email_on_review_of_review"
    t.boolean "is_new_user",                              :default => true
    t.boolean "master_permission_granted"
    t.string  "handle"
    t.boolean "leaderboard_privacy",                      :default => false
    t.text    "digital_certificate"
    t.string  "persistence_token"
  end

  add_index "users", ["role_id"], :name => "fk_user_role_id"

  create_table "wiki_types", :force => true do |t|
    t.string "name", :default => "", :null => false
  end

end
