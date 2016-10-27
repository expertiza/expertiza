require 'rails_helper'

def expect_deadline_check(deadline_condition)
  if deadline_condition.eql? 'Submission deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for submission deadline to signed-up users '
    display_condition = "submission"
  end
  if deadline_condition.eql? 'Review deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for review deadline to reviewers '
    display_condition = "review"
  end
  if deadline_condition.eql? 'Metareview deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for Metareview deadline to reviewers '
    display_condition = "metareview"
  end
  if deadline_condition.eql? 'Drop Topic deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for drop topic deadline to reviewers '
    display_condition = "drop_topic"
  end
  if deadline_condition.eql? 'Signup deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for signup deadline to reviewers '
    display_condition = "signup"
  end
  if deadline_condition.eql? 'Team formation deadline reminder email'
    send_reminder_condition = 'is able to send reminder email for team formation deadline to reviewers '
    display_condition = "team_formation"
  end
 
