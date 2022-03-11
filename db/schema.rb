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

ActiveRecord::Schema.define(version: 20_220_111_023_859) do
  create_table 'account_requests', force: :cascade do |t|
    t.string   'name',              limit: 255
    t.bigint  'role_id',           limit: 4
    t.string   'fullname',          limit: 255
    t.bigint   'institution_id',    limit: 255
    t.string   'email',             limit: 255
    t.string   'status',            limit: 255
    t.datetime 'created_at',                      null: false
    t.datetime 'updated_at',                      null: false
    t.text     'self_introduction', limit: 65_535
  end

  create_table 'answer_tags', force: :cascade do |t|
    t.bigint  'answer_id',                limit: 4
    t.bigint  'tag_prompt_deployment_id', limit: 4
    t.bigint  'user_id',                  limit: 4
    t.string   'value', limit: 255
    t.datetime 'created_at',                           null: false
    t.datetime 'updated_at',                           null: false
  end

  add_index 'answer_tags', ['answer_id'], name: 'index_answer_tags_on_answer_id', using: :btree
  add_index 'answer_tags', ['tag_prompt_deployment_id'], name: 'index_answer_tags_on_tag_prompt_deployment_id', using: :btree
  add_index 'answer_tags', ['user_id'], name: 'index_answer_tags_on_user_id', using: :btree

  create_table 'answers', force: :cascade do |t|
    t.bigint 'question_id', limit: 4, default: 0, null: false
    t.integer 'answer',      limit: 4
    t.text    'comments',    limit: 65_535
    t.bigint 'response_id', limit: 4
  end

  add_index 'answers', ['question_id'], name: 'fk_score_questions', using: :btree
  add_index 'answers', ['response_id'], name: 'fk_score_response', using: :btree

  create_table 'assignment_badges', force: :cascade do |t|
    t.bigint  'badge_id',      limit: 4
    t.integer  'assignment_id', limit: 4
    t.integer  'threshold', limit: 4
    t.datetime 'created_at',              null: false
    t.datetime 'updated_at',              null: false
  end

  add_index 'assignment_badges', ['assignment_id'], name: 'index_assignment_badges_on_assignment_id', using: :btree
  add_index 'assignment_badges', ['badge_id'], name: 'index_assignment_badges_on_badge_id', using: :btree

  create_table 'assignment_questionnaires', force: :cascade do |t|
    t.integer 'assignment_id',        limit: 4
    t.bigint 'questionnaire_id',     limit: 4
    t.bigint 'user_id',              limit: 4
    t.integer 'notification_limit',   limit: 4, default: 15,   null: false
    t.integer 'questionnaire_weight', limit: 4, default: 0,    null: false
    t.integer 'used_in_round',        limit: 4
    t.boolean 'dropdown', default: true
    t.bigint 'topic_id',             limit: 4
    t.bigint 'duty_id',              limit: 4
  end

  add_index 'assignment_questionnaires', ['assignment_id'], name: 'fk_aq_assignments_id', using: :btree
  add_index 'assignment_questionnaires', ['duty_id'], name: 'index_assignment_questionnaires_on_duty_id', using: :btree
  add_index 'assignment_questionnaires', ['questionnaire_id'], name: 'fk_aq_questionnaire_id', using: :btree
  add_index 'assignment_questionnaires', ['user_id'], name: 'fk_aq_user_id', using: :btree

  create_table 'assignments', force: :cascade do |t|
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'name',                                               limit: 255
    t.string   'directory_path',                                     limit: 255
    t.integer  'submitter_count',                                    limit: 4, default: 0, null: false
    t.bigint  'course_id',                                          limit: 4,     default: 0
    t.bigint  'instructor_id',                                      limit: 4,     default: 0
    t.boolean  'private',                                                          default: false,           null: false
    t.integer  'num_reviews',                                        limit: 4,     default: 3,               null: false
    t.integer  'num_review_of_reviews',                              limit: 4,     default: 0,               null: false
    t.integer  'num_review_of_reviewers',                            limit: 4,     default: 0,               null: false
    t.boolean  'reviews_visible_to_all'
    t.integer  'num_reviewers',                                      limit: 4, default: 0, null: false
    t.text     'spec_location',                                      limit: 65_535
    t.integer  'max_team_size',                                      limit: 4, default: 0, null: false
    t.boolean  'staggered_deadline'
    t.boolean  'allow_suggestions'
    t.integer  'days_between_submissions',                           limit: 4
    t.string   'review_assignment_strategy',                         limit: 255
    t.integer  'max_reviews_per_submission',                         limit: 4
    t.integer  'review_topic_threshold',                             limit: 4,     default: 0
    t.boolean  'copy_flag',                                                        default: false
    t.integer  'rounds_of_reviews', limit: 4, default: 1
    t.boolean  'microtask', default: false
    t.boolean  'require_quiz'
    t.integer  'num_quiz_questions', limit: 4, default: 0, null: false
    t.boolean  'is_coding_assignment'
    t.boolean  'is_intelligent'
    t.boolean  'calculate_penalty', default: false, null: false
    t.bigint 'late_policy_id', limit: 4
    t.boolean  'is_penalty_calculated', default: false, null: false
    t.integer  'max_bids', limit: 4
    t.boolean  'show_teammate_reviews'
    t.boolean  'availability_flag', default: true
    t.boolean  'use_bookmark'
    t.boolean  'can_review_same_topic',                                            default: true
    t.boolean  'can_choose_topic_to_review',                                       default: true
    t.boolean  'is_calibrated',                                                    default: false
    t.boolean  'is_selfreview_enabled'
    t.string   'reputation_algorithm', limit: 255, default: 'Lauw'
    t.boolean  'is_anonymous',                                                     default: true
    t.integer  'num_reviews_required',                               limit: 4,     default: 3
    t.integer  'num_metareviews_required',                           limit: 4,     default: 3
    t.integer  'num_metareviews_allowed',                            limit: 4,     default: 3
    t.integer  'num_reviews_allowed',                                limit: 4,     default: 3
    t.integer  'simicheck',                                          limit: 4,     default: -1
    t.integer  'simicheck_threshold',                                limit: 4,     default: 100
    t.boolean  'is_answer_tagging_allowed'
    t.boolean  'has_badge'
    t.boolean  'allow_selecting_additional_reviews_after_1st_round'
    t.bigint 'sample_assignment_id', limit: 4
    t.boolean  'vary_by_topic',                                                    default: false
    t.boolean  'vary_by_round',                                                    default: false
    t.boolean  'reviewer_is_team'
    t.string   'review_choosing_algorithm', limit: 255, default: 'Simple Choose'
    t.boolean  'is_conference_assignment',                                         default: false
    t.boolean  'auto_assign_mentor',                                               default: false
    t.boolean  'duty_based_assignment?'
    t.boolean  'questionnaire_varies_by_duty'
  end

  add_index 'assignments', ['course_id'], name: 'fk_assignments_courses', using: :btree
  add_index 'assignments', ['instructor_id'], name: 'fk_assignments_instructors', using: :btree
  add_index 'assignments', ['late_policy_id'], name: 'fk_late_policy_id', using: :btree
  add_index 'assignments', ['sample_assignment_id'], name: 'fk_rails_b01b82a1a2', using: :btree

  create_table 'automated_metareviews', force: :cascade do |t|
    t.float    'relevance',         limit: 24
    t.float    'content_summative', limit: 24
    t.float    'content_problem',   limit: 24
    t.float    'content_advisory',  limit: 24
    t.float    'tone_positive',     limit: 24
    t.float    'tone_negative',     limit: 24
    t.float    'tone_neutral',      limit: 24
    t.integer  'quantity',          limit: 4
    t.integer  'plagiarism',        limit: 4
    t.integer  'version_num',       limit: 4
    t.bigint 'response_id', limit: 4
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'automated_metareviews', ['response_id'], name: 'fk_automated_metareviews_responses_id', using: :btree

  create_table 'awarded_badges', force: :cascade do |t|
    t.bigint  'badge_id',        limit: 4
    t.bigint  'participant_id',  limit: 4
    t.datetime 'created_at',                null: false
    t.datetime 'updated_at',                null: false
    t.integer  'approval_status', limit: 4
  end

  add_index 'awarded_badges', ['badge_id'], name: 'index_awarded_badges_on_badge_id', using: :btree
  add_index 'awarded_badges', ['participant_id'], name: 'index_awarded_badges_on_participant_id', using: :btree

  create_table 'badges', force: :cascade do |t|
    t.string   'name',        limit: 255
    t.string   'description', limit: 255
    t.string   'image_name',  limit: 255
    t.datetime 'created_at',              null: false
    t.datetime 'updated_at',              null: false
  end

  create_table 'bids', force: :cascade do |t|
    t.bigint  'topic_id',   limit: 4
    t.bigint  'team_id',    limit: 4
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'priority', limit: 4
  end

  add_index 'bids', ['team_id'], name: 'index_bids_on_team_id', using: :btree
  add_index 'bids', ['topic_id'], name: 'index_bids_on_topic_id', using: :btree

  create_table 'bookmark_ratings', force: :cascade do |t|
    t.bigint  'bookmark_id', limit: 4
    t.bigint  'user_id',     limit: 4
    t.integer  'rating', limit: 4
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'bookmarks', force: :cascade do |t|
    t.text     'url',         limit: 65_535
    t.text     'title',       limit: 65_535
    t.text     'description', limit: 65_535
    t.bigint  'user_id',     limit: 4
    t.bigint  'topic_id',    limit: 4
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'bookmarks', ['topic_id'], name: 'index_bookmarks_on_topic_id', using: :btree

  create_table 'calculated_penalties', force: :cascade do |t|
    t.bigint 'participant_id',   limit: 4
    t.bigint 'deadline_type_id', limit: 4
    t.integer 'penalty_points',   limit: 4
  end

  create_table 'content_pages', force: :cascade do |t|
    t.string   'title',           limit: 255
    t.string   'name',            limit: 255, default: '', null: false
    t.bigint 'markup_style_id', limit: 4
    t.text 'content', limit: 65_535
    t.bigint 'permission_id', limit: 4, default: 0, null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.text     'content_cache', limit: 65_535
  end

  add_index 'content_pages', ['markup_style_id'], name: 'fk_content_page_markup_style_id', using: :btree
  add_index 'content_pages', ['permission_id'], name: 'fk_content_page_permission_id', using: :btree

  create_table 'controller_actions', force: :cascade do |t|
    t.bigint 'site_controller_id', limit: 4, default: 0, null: false
    t.string 'name', limit: 255, default: '', null: false
    t.bigint 'permission_id', limit: 4
    t.string 'url_to_use', limit: 255
  end

  create_table 'courses', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string   'name'
    t.bigint  'instructor_id'
    t.string   'directory_path'
    t.text     'info', limit: 65_535
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'private', default: false, null: false
    t.integer  'institutions_id'
    t.integer  'locale', default: 1
    t.index ['instructor_id'], name: 'fk_course_users', using: :btree
  end

  create_table 'deadline_rights', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string 'name', limit: 32
  end

  create_table 'deadline_types', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string 'name', limit: 32
  end

  create_table 'delayed_jobs', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.integer  'priority',                 default: 0
    t.integer  'attempts',                 default: 0
    t.text     'handler',    limit: 65_535
    t.text     'last_error', limit: 65_535
    t.datetime 'run_at'
    t.datetime 'locked_at'
    t.datetime 'failed_at'
    t.string   'locked_by'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'queue'
    t.index %w[priority run_at], name: 'delayed_jobs_priority', using: :btree
  end

  create_table 'due_dates', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.datetime 'due_at'
    t.bigint  'deadline_type_id'
    t.bigint  'parent_id'
    t.bigint  'submission_allowed_id'
    t.bigint  'review_allowed_id'
    t.bigint  'review_of_review_allowed_id'
    t.integer  'round'
    t.boolean  'flag',                        default: false
    t.integer  'threshold',                   default: 1
    t.string   'delayed_job_id'
    t.string   'deadline_name'
    t.string   'description_url'
    t.bigint  'quiz_allowed_id',             default: 1
    t.bigint  'teammate_review_allowed_id',  default: 3
    t.string 'type', default: 'AssignmentDueDate'
    t.index ['deadline_type_id'], name: 'fk_deadline_type_due_date', using: :btree
    t.index ['parent_id'], name: 'fk_due_dates_assignments', using: :btree
    t.index ['review_allowed_id'], name: 'fk_due_date_review_allowed', using: :btree
    t.index ['review_of_review_allowed_id'], name: 'fk_due_date_review_of_review_allowed', using: :btree
    t.index ['submission_allowed_id'], name: 'fk_due_date_submission_allowed', using: :btree
  end

  create_table 'duties', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string   'name'
    t.integer  'max_members_for_duty'
    t.integer 'assignment_id'
    t.datetime 'created_at',           null: false
    t.datetime 'updated_at',           null: false
    t.index ['assignment_id'], name: 'index_duties_on_assignment_id', using: :btree
  end

  create_table 'institutions', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string 'name', default: '', null: false
  end

  create_table 'invitations', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.integer 'assignment_id'
    t.bigint 'from_id'
    t.bigint 'to_id'
    t.string  'reply_status',  limit: 1
    t.index ['assignment_id'], name: 'fk_invitation_assignments', using: :btree
    t.index ['from_id'], name: 'fk_invitationfrom_users', using: :btree
    t.index ['to_id'], name: 'fk_invitationto_users', using: :btree
  end

  create_table 'join_team_requests', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.integer  'participant_id'
    t.integer  'team_id'
    t.text     'comments',       limit: 65_535
    t.string   'status',         limit: 1
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'languages', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string 'name', limit: 32
  end

  create_table 'late_policies', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.float   'penalty_per_unit', limit: 24
    t.integer 'max_penalty', default: 0, null: false
    t.string  'penalty_unit', null: false
    t.integer 'times_used', default: 0, null: false
    t.bigint 'instructor_id', null: false
    t.string 'policy_name', null: false
    t.index ['instructor_id'], name: 'fk_instructor_id', using: :btree
  end

  create_table 'locks', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.integer  'timeout_period'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.bigint 'user_id'
    t.string   'lockable_type'
    t.integer  'lockable_id'
    t.index ['user_id'], name: 'fk_rails_426f571216', using: :btree
  end

  create_table 'markup_styles', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string 'name', default: '', null: false
  end

  create_table 'menu_items', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint 'parent_id'
    t.string  'name',                 default: '', null: false
    t.string  'label',                default: '', null: false
    t.integer 'seq'
    t.bigint 'controller_action_id'
    t.bigint 'content_page_id'
    t.bigint ['content_page_id'], name: 'fk_menu_item_content_page_id', using: :btree
    t.index ['controller_action_id'], name: 'fk_menu_item_controller_action_id', using: :btree
    t.index ['parent_id'], name: 'fk_menu_item_parent_id', using: :btree
  end

  create_table 'nodes', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.integer 'parent_id'
    t.integer 'node_object_id'
    t.string  'type'
  end

  create_table 'notifications', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string   'subject'
    t.text     'description', limit: 65_535
    t.date     'expiration_date'
    t.boolean  'active_flag'
    t.datetime 'created_at',                    null: false
    t.datetime 'updated_at',                    null: false
    t.bigint  'course_id'
    t.index ['course_id'], name: 'index_notifications_on_course_id', using: :btree
  end

  create_table 'participants', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.boolean  'can_submit',                        default: true
    t.boolean  'can_review',                        default: true
    t.bigint  'user_id'
    t.bigint  'parent_id'
    t.datetime 'submitted_at'
    t.boolean  'permission_granted'
    t.integer  'penalty_accumulated', default: 0, null: false, unsigned: true
    t.float    'grade', limit: 24
    t.string   'type'
    t.string   'handle'
    t.datetime 'time_stamp'
    t.text     'digital_signature', limit: 65_535
    t.string   'duty'
    t.boolean  'can_take_quiz',                     default: true
    t.float    'Hamer',               limit: 24,    default: 1.0
    t.float    'Lauw',                limit: 24,    default: 0.0
    t.bigint  'duty_id'
    t.index ['duty_id'], name: 'index_participants_on_duty_id', using: :btree
    t.index ['user_id'], name: 'fk_participant_users', using: :btree
  end

  create_table 'password_resets', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string   'user_email'
    t.string   'token'
    t.datetime 'updated_at'
  end

  create_table 'permissions', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string 'name', default: '', null: false
  end

  create_table 'plagiarism_checker_assignment_submissions', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string   'name'
    t.string   'simicheck_id'
    t.datetime 'created_at',    null: false
    t.datetime 'updated_at',    null: false
    t.integer  'assignment_id'
    t.index ['assignment_id'], name: 'index_plagiarism_checker_assgt_subm_on_assignment_id', using: :btree
  end

  create_table 'plagiarism_checker_comparisons', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.bigint  'plagiarism_checker_assignment_submission_id'
    t.string   'similarity_link'
    t.decimal  'similarity_percentage', precision: 10
    t.string   'file1_name'
    t.string   'file1_id'
    t.string   'file1_team'
    t.string   'file2_name'
    t.string   'file2_id'
    t.string   'file2_team'
    t.datetime 'created_at',                                                 null: false
    t.datetime 'updated_at',                                                 null: false
    t.index ['plagiarism_checker_assignment_submission_id'], name: 'assignment_submission_index', using: :btree
  end

  create_table 'question_advices', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint 'question_id'
    t.integer 'score'
    t.text    'advice',      limit: 65_535
    t.index ['question_id'], name: 'fk_question_question_advices', using: :btree
  end

  create_table 'questionnaires', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string   'name', limit: 64
    t.bigint 'instructor_id', default: 0, null: false
    t.boolean  'private',                          default: false, null: false
    t.integer  'min_question_score',               default: 0,     null: false
    t.integer  'max_question_score'
    t.datetime 'created_at'
    t.datetime 'updated_at', null: false
    t.string   'type'
    t.string   'display_type'
    t.text     'instruction_loc', limit: 65_535
  end

  create_table 'questions', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.text    'txt', limit: 65_535
    t.integer 'weight'
    t.bigint 'questionnaire_id'
    t.decimal 'seq', precision: 6, scale: 2
    t.string  'type'
    t.string  'size', default: ''
    t.string  'alternatives'
    t.boolean 'break_before',                                           default: true
    t.string  'max_label',                                              default: ''
    t.string  'min_label',                                              default: ''
    t.index ['questionnaire_id'], name: 'fk_question_questionnaires', using: :btree
  end

  create_table 'quiz_question_choices', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.integer 'question_id'
    t.text    'txt', limit: 65_535
    t.boolean 'iscorrect', default: false
  end

  create_table 'response_maps', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint  'reviewed_object_id', default: 0,     null: false
    t.bigint  'reviewer_id',        default: 0,     null: false
    t.bigint  'reviewee_id',        default: 0,     null: false
    t.string   'type', default: '', null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'calibrate_to', default: false
    t.boolean  'reviewer_is_team'
    t.index ['reviewer_id'], name: 'fk_response_map_reviewer', using: :btree
  end

  create_table 'responses', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint 'map_id', default: 0, null: false
    t.text     'additional_comment', limit: 65_535
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'version_num'
    t.integer  'round'
    t.boolean  'is_submitted',                     default: false
    t.string   'visibility',                       default: 'private'
    t.index ['map_id'], name: 'fk_response_response_map', using: :btree
  end

  create_table 'resubmission_times', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint  'participant_id'
    t.datetime 'resubmitted_at'
    t.index ['participant_id'], name: 'fk_resubmission_times_participants', using: :btree
  end

  create_table 'review_bids', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.integer  'priority'
    t.bigint  'signuptopic_id'
    t.bigint  'participant_id'
    t.datetime 'created_at',     null: false
    t.datetime 'updated_at',     null: false
    t.bigint 'user_id'
    t.integer 'assignment_id'
    t.index ['assignment_id'], name: 'fk_rails_549e23ae08', using: :btree
    t.index ['participant_id'], name: 'fk_rails_ab93feeb35', using: :btree
    t.index ['signuptopic_id'], name: 'fk_rails_e88fa4058f', using: :btree
    t.index ['user_id'], name: 'fk_rails_6041e1cdb9', using: :btree
  end

  create_table 'review_comment_paste_bins', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.bigint 'review_grade_id'
    t.string   'title'
    t.text     'review_comment', limit: 65_535
    t.datetime 'created_at',                    null: false
    t.datetime 'updated_at',                    null: false
    t.index ['review_grade_id'], name: 'fk_rails_0a539bcc81', using: :btree
  end

  create_table 'review_grades', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.bigint 'participant_id'
    t.integer  'grade_for_reviewer'
    t.text     'comment_for_reviewer', limit: 65_535
    t.datetime 'review_graded_at'
    t.integer  'reviewer_id'
    t.index ['participant_id'], name: 'fk_rails_29587cf6a9', using: :btree
  end

  create_table 'roles', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string   'name', default: '', null: false
    t.integer  'parent_id'
    t.string   'description', default: '', null: false
    t.integer  'default_page_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index ['default_page_id'], name: 'fk_role_default_page_id', using: :btree
    t.index ['parent_id'], name: 'fk_role_parent_id', using: :btree
  end

  create_table 'roles_permissions', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint 'role_id',       default: 0, null: false
    t.bigint 'permission_id', default: 0, null: false
    t.index ['permission_id'], name: 'fk_roles_permission_permission_id', using: :btree
    t.index ['role_id'], name: 'fk_roles_permission_role_id', using: :btree
  end

  create_table 'sample_reviews', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.integer  'assignment_id'
    t.integer  'response_id'
    t.datetime 'created_at',    null: false
    t.datetime 'updated_at',    null: false
  end

  create_table 'sections', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci' do |t|
    t.string   'name', null: false
    t.text     'desc_text', limit: 65_535
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'sessions', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string   'session_id', default: '', null: false
    t.text     'data', limit: 16_777_215
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index ['session_id'], name: 'index_sessions_on_session_id', using: :btree
    t.index ['updated_at'], name: 'index_sessions_on_updated_at', using: :btree
  end

  create_table 'sign_up_topics', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.text 'topic_name',       limit: 65_535, null: false
    t.integer 'assignment_id',                  default: 0, null: false
    t.integer 'max_choosers',                   default: 0, null: false
    t.text    'category',         limit: 65_535
    t.string  'topic_identifier', limit: 10
    t.integer 'micropayment', default: 0
    t.integer 'private_to'
    t.text    'description', limit: 65_535
    t.string  'link'
    t.index ['assignment_id'], name: 'fk_sign_up_categories_sign_up_topics', using: :btree
    t.index ['assignment_id'], name: 'index_sign_up_topics_on_assignment_id', using: :btree
  end

  create_table 'signed_up_teams', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint 'topic_id',                   default: 0,     null: false
    t.integer 'team_id',                    default: 0,     null: false
    t.boolean 'is_waitlisted',              default: false, null: false
    t.integer 'preference_priority_number'
    t.index ['topic_id'], name: 'fk_signed_up_users_sign_up_topics', using: :btree
  end

  create_table 'site_controllers', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string  'name',          default: '', null: false
    t.integer 'permission_id', default: 0,  null: false
    t.integer 'builtin',       default: 0
    t.index ['permission_id'], name: 'fk_site_controller_permission_id', using: :btree
  end

  create_table 'submission_records', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.datetime 'created_at',                  null: false
    t.datetime 'updated_at',                  null: false
    t.text     'type', limit: 65_535
    t.string   'content'
    t.string   'operation'
    t.integer  'team_id'
    t.string   'user'
    t.integer  'assignment_id'
  end

  create_table 'suggestion_comments', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.text     'comments', limit: 65_535
    t.string   'commenter'
    t.string   'vote'
    t.integer  'suggestion_id'
    t.datetime 'created_at'
  end

  create_table 'suggestions', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.integer 'assignment_id'
    t.string  'title'
    t.text    'description', limit: 65_535
    t.string  'status'
    t.string  'unityID'
    t.string  'signup_preference'
  end

  create_table 'survey_deployments', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint  'questionnaire_id'
    t.datetime 'start_date'
    t.datetime 'end_date'
    t.datetime 'last_reminder'
    t.integer  'parent_id', default: 0, null: false
    t.integer  'global_survey_id'
    t.string   'type'
    t.index ['questionnaire_id'], name: 'fk_rails_7c62b6ef2b', using: :btree
  end

  create_table 'system_settings', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string  'site_name', default: '', null: false
    t.string  'site_subtitle'
    t.string  'footer_message',            default: ''
    t.bigint 'public_role_id',            default: 0,  null: false
    t.integer 'session_timeout',           default: 0,  null: false
    t.integer 'default_markup_style_id',   default: 0
    t.bigint 'site_default_page_id',      default: 0,  null: false
    t.bigint 'not_found_page_id',         default: 0,  null: false
    t.bigint 'permission_denied_page_id', default: 0,  null: false
    t.bigint 'session_expired_page_id',   default: 0,  null: false
    t.integer 'menu_depth',                default: 0,  null: false
    t.index ['not_found_page_id'], name: 'fk_system_settings_not_found_page_id', using: :btree
    t.index ['permission_denied_page_id'], name: 'fk_system_settings_permission_denied_page_id', using: :btree
    t.index ['public_role_id'], name: 'fk_system_settings_public_role_id', using: :btree
    t.index ['session_expired_page_id'], name: 'fk_system_settings_session_expired_page_id', using: :btree
    t.index ['site_default_page_id'], name: 'fk_system_settings_site_default_page_id', using: :btree
  end

  create_table 'ta_mappings', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint 'ta_id'
    t.bigint 'course_id'
    t.index ['course_id'], name: 'fk_ta_mappings_course_id', using: :btree
    t.index ['ta_id'], name: 'fk_ta_mappings_ta_id', using: :btree
  end

  create_table 'tag_prompt_deployments', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint  'tag_prompt_id'
    t.integer  'assignment_id'
    t.bigint  'questionnaire_id'
    t.string   'question_type'
    t.integer  'answer_length_threshold'
    t.datetime 'created_at',              null: false
    t.datetime 'updated_at',              null: false
    t.index ['assignment_id'], name: 'index_tag_prompt_deployments_on_assignment_id', using: :btree
    t.index ['questionnaire_id'], name: 'index_tag_prompt_deployments_on_questionnaire_id', using: :btree
    t.index ['tag_prompt_id'], name: 'index_tag_prompt_deployments_on_tag_prompt_id', using: :btree
  end

  create_table 'tag_prompts', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string   'prompt'
    t.string   'desc'
    t.string   'control_type'
    t.datetime 'created_at',   null: false
    t.datetime 'updated_at',   null: false
  end

  create_table 'teams', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string  'name'
    t.integer 'parent_id'
    t.string  'type'
    t.text    'comments_for_advertisement', limit: 65_535
    t.boolean 'advertise_for_partner'
    t.text    'submitted_hyperlinks', limit: 65_535
    t.integer 'directory_num'
    t.integer 'grade_for_submission'
    t.text    'comment_for_submission', limit: 65_535
  end

  create_table 'teams_users', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint 'team_id'
    t.bigint 'user_id'
    t.bigint 'duty_id'
    t.index ['duty_id'], name: 'index_teams_users_on_duty_id', using: :btree
    t.index ['team_id'], name: 'fk_users_teams', using: :btree
    t.index ['user_id'], name: 'fk_teams_users', using: :btree
  end

  create_table 'track_notifications', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.bigint  'notification_id'
    t.bigint  'user_id'
    t.datetime 'created_at',      null: false
    t.datetime 'updated_at',      null: false
    t.index ['notification_id'], name: 'index_track_notifications_on_notification_id', using: :btree
    t.index ['user_id'], name: 'index_track_notifications_on_user_id', using: :btree
  end

  create_table 'tree_folders', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=latin1' do |t|
    t.string  'name'
    t.string  'child_type'
    t.integer 'parent_id'
  end

  create_table 'user_pastebins', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.integer  'user_id'
    t.string   'short_form'
    t.text     'long_form', limit: 65_535
    t.datetime 'created_at',               null: false
    t.datetime 'updated_at',               null: false
  end

  create_table 'users', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string  'name', default: '', null: false
    t.string  'crypted_password', limit: 40, default: '', null: false
    t.bigint 'role_id', default: 0, null: false
    t.string  'password_salt'
    t.string  'fullname'
    t.string  'email'
    t.integer 'parent_id'
    t.boolean 'private_by_default', default: false
    t.string  'mru_directory_path', limit: 128
    t.boolean 'email_on_review'
    t.boolean 'email_on_submission'
    t.boolean 'email_on_review_of_review'
    t.boolean 'is_new_user',                                default: true, null: false
    t.integer 'master_permission_granted', limit: 1,        default: 0
    t.string  'handle'
    t.text    'digital_certificate', limit: 16_777_215
    t.string  'persistence_token'
    t.string  'timezonepref'
    t.text    'public_key', limit: 16_777_215
    t.boolean 'copy_of_emails', default: false
    t.integer 'institution_id'
    t.boolean 'preference_home_flag',                       default: true
    t.integer 'locale',                                     default: 0
    t.index ['role_id'], name: 'fk_user_role_id', using: :btree
  end

  create_table 'versions', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string   'item_type',                   null: false
    t.integer  'item_id',                     null: false
    t.string   'event',                       null: false
    t.string   'whodunnit'
    t.text     'object', limit: 16_777_215
    t.datetime 'created_at'
    t.index %w[item_type item_id], name: 'index_versions_on_item_type_and_item_id', using: :btree
  end

  add_foreign_key 'answer_tags', 'answers'
  add_foreign_key 'answer_tags', 'tag_prompt_deployments'
  add_foreign_key 'answer_tags', 'users'
  add_foreign_key 'answers', 'questions', name: 'fk_score_questions'
  add_foreign_key 'answers', 'responses', name: 'fk_score_response'
  add_foreign_key 'assignment_badges', 'assignments'
  add_foreign_key 'assignment_badges', 'badges'
  add_foreign_key 'assignment_questionnaires', 'assignments', name: 'fk_aq_assignments_id'
  add_foreign_key 'assignment_questionnaires', 'duties'
  add_foreign_key 'assignment_questionnaires', 'questionnaires', name: 'fk_aq_questionnaire_id'
  add_foreign_key 'assignments', 'late_policies', name: 'fk_late_policy_id'
  add_foreign_key 'assignments', 'users', column: 'instructor_id', name: 'fk_assignments_instructors'
  add_foreign_key 'automated_metareviews', 'responses', name: 'fk_automated_metareviews_responses_id'
  add_foreign_key 'awarded_badges', 'badges'
  add_foreign_key 'awarded_badges', 'participants'
  add_foreign_key 'courses', 'users', column: 'instructor_id', name: 'fk_course_users'
  add_foreign_key 'due_dates', 'deadline_rights', column: 'review_allowed_id', name: 'fk_due_date_review_allowed'
  add_foreign_key 'due_dates', 'deadline_rights', column: 'review_of_review_allowed_id', name: 'fk_due_date_review_of_review_allowed'
  add_foreign_key 'due_dates', 'deadline_rights', column: 'submission_allowed_id', name: 'fk_due_date_submission_allowed'
  add_foreign_key 'due_dates', 'deadline_types', name: 'fk_deadline_type_due_date'
  add_foreign_key 'duties', 'assignments'
  add_foreign_key 'invitations', 'assignments', name: 'fk_invitation_assignments'
  add_foreign_key 'invitations', 'users', column: 'from_id', name: 'fk_invitationfrom_users'
  add_foreign_key 'invitations', 'users', column: 'to_id', name: 'fk_invitationto_users'
  add_foreign_key 'late_policies', 'users', column: 'instructor_id', name: 'fk_instructor_id'
  add_foreign_key 'locks', 'users'
  add_foreign_key 'participants', 'duties'
  add_foreign_key 'participants', 'users', name: 'fk_participant_users'
  add_foreign_key 'plagiarism_checker_assignment_submissions', 'assignments'
  add_foreign_key 'plagiarism_checker_comparisons', 'plagiarism_checker_assignment_submissions'
  add_foreign_key 'question_advices', 'questions', name: 'fk_question_question_advices'
  add_foreign_key 'questions', 'questionnaires', name: 'fk_question_questionnaires'
  add_foreign_key 'resubmission_times', 'participants', name: 'fk_resubmission_times_participants'
  add_foreign_key 'review_bids', 'assignments'
  add_foreign_key 'review_bids', 'participants'
  add_foreign_key 'review_bids', 'sign_up_topics', column: 'signuptopic_id'
  add_foreign_key 'review_bids', 'users'
  add_foreign_key 'review_comment_paste_bins', 'review_grades'
  add_foreign_key 'review_grades', 'participants'
  add_foreign_key 'sign_up_topics', 'assignments', name: 'fk_sign_up_topics_assignments'
  add_foreign_key 'signed_up_teams', 'sign_up_topics', column: 'topic_id', name: 'fk_signed_up_users_sign_up_topics'
  add_foreign_key 'survey_deployments', 'questionnaires'
  add_foreign_key 'ta_mappings', 'courses', name: 'fk_ta_mappings_course_id'
  add_foreign_key 'ta_mappings', 'users', column: 'ta_id', name: 'fk_ta_mappings_ta_id'
  add_foreign_key 'tag_prompt_deployments', 'assignments'
  add_foreign_key 'tag_prompt_deployments', 'questionnaires'
  add_foreign_key 'tag_prompt_deployments', 'tag_prompts'
  add_foreign_key 'teams_users', 'duties'
  add_foreign_key 'teams_users', 'teams', name: 'fk_users_teams'
  add_foreign_key 'teams_users', 'users', name: 'fk_teams_users'
  add_foreign_key 'track_notifications', 'notifications'
  add_foreign_key 'track_notifications', 'users'
end
