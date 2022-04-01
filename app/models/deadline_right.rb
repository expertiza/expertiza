class DeadlineRight < ApplicationRecord
  NO = 1
  LATE = 2
  OK   = 3
  DEFAULT_PERMISSION = {
    'signup' => {
      'submission_allowed' => OK,
      'can_review' => NO,
      'review_of_review_allowed' => NO
    },
    'team_formation' => {
      'submission_allowed' => OK,
      'can_review' => NO,
      'review_of_review_allowed' => NO
    },
    'drop_topic' => {
      'submission_allowed' => OK,
      'can_review' => NO,
      'review_of_review_allowed' => NO
    },
    'submission' => {
      'submission_allowed' => OK,
      'can_review' => NO,
      'review_of_review_allowed' => NO
    },
    'review' => {
      'submission_allowed' => NO,
      'can_review' => OK,
      'review_of_review_allowed' => NO
    },
    'metareview' => {
      'submission_allowed' => NO,
      'can_review' => NO,
      'review_of_review_allowed' => OK
    }
  }.freeze
end
