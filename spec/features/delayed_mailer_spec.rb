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
  describe deadline_condition do
    it send_reminder_condition do
      @name = "user"
      # due_at = DateTime.now.getlocal.advance(minutes: +2)
      # due_at1 = Time.parse.getlocal(due_at.to_s(:db))
      # curr_time = DateTime.now.getlocal.to_s(:db)
      # curr_time = Time.parse.getlocal(curr_time)
      Delayed::Job.delete_all
      expect(Delayed::Job.count).to eq(0)
      expect(Delayed::Job.count).to eq(1)
      expect(Delayed::Job.last.handler).to include("deadline_type: " + display_condition)
    end
  end
end
expect_deadline_check('Submission deadline reminder email')
expect_deadline_check('Review deadline reminder email')
expect_deadline_check('Metareview deadline reminder email')
expect_deadline_check('Drop Topic deadline reminder email')
expect_deadline_check('Signup deadline reminder email')
expect_deadline_check('Team formation deadline reminder email')
