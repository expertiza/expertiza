require 'rails_helper'

def expect_deadline_check(deadline_condition, send_reminder_condition, display_condition, dj_condition)
  describe deadline_condition do
    it send_reminder_condition do
      # Delayed::Worker.delay_jobs = false
      id = 2
      @name = "user"

      # due_at = DateTime.now + 120
      # seconds_until_due = due_at - Time.now
      # minutes_until_due = seconds_until_due / 60
      due_at = DateTime.now.advance(minutes: +2)
  
      # puts DateTime.now
      # puts due_at
      due_at1 = Time.parse(due_at.to_s(:db))
      curr_time = DateTime.now.to_s(:db)
      curr_time = Time.parse(curr_time)
      time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
      Delayed::Job.delete_all
      expect(Delayed::Job.count).to eq(0)
  
      dj = Delayed::Job.enqueue(payload_object: DelayedMailer.new(id, dj_condition, due_at), priority: 1, run_at: time_in_min)
  
      expect(Delayed::Job.count).to eq(1)
  
      expect(Delayed::Job.last.handler).to include(display_condition)
    end
  end
end

expect_deadline_check('Submission deadline reminder email', 'is able to send reminder email for submission deadline to signed-up users ', "deadline_type: submission", "submission")
expect_deadline_check('Review deadline reminder email', 'is able to send reminder email for review deadline to reviewers ', "deadline_type: review", "review")
expect_deadline_check('Metareview deadline reminder email', 'is able to send reminder email for Metareview deadline to reviewers ', "deadline_type: metareview", "metareview")
expect_deadline_check('Drop Topic deadline reminder email', 'is able to send reminder email for drop topic deadline to reviewers ', "deadline_type: drop_topic", "drop_topic")
expect_deadline_check('Signup deadline reminder email', 'is able to send reminder email for signup deadline to reviewers ', "deadline_type: signup", "signup")
expect_deadline_check('Team formation deadline reminder email', 'is able to send reminder email for team formation deadline to reviewers ', "deadline_type: team_formation", "team_formation")
