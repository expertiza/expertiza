require 'rails_helper'
deadline_reminder_email_type = 'Submission deadline reminder email'
send_reminder_is_condition = 'is able to send reminder email for submission deadline to signed-up users '
deadlne_type = "deadline_type: submission"
display_deadline = "submission"
expect_deadline_check(deadline_reminder_email_type, send_reminder_is_condition, deadlne_type, display_deadline)

deadline_reminder_email_type = 'Metareview deadline reminder email'
send_reminder_is_condition = 'is able to send reminder email for submission deadline to signed-up users '
deadlne_type = "deadline_type: submission"
display_deadline = "submission"
expect_deadline_check(deadline_reminder_email_type, send_reminder_is_condition, deadlne_type, display_deadline)


describe 'Review deadline reminder email' do
  it 'is able to send reminder email for review deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.current.advance(minutes: +2)

    due_at1 = Time.zone.parse(due_at.to_s(:db))
    curr_time = DateTime.current.to_s(:db)
    curr_time = Time.zone.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    dj = Delayed::Job.enqueue(payload_object: ScheduledTask.new(id, "review", due_at), priority: 1, run_at: time_in_min)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: review")
    dj2 = Delayed::Job.enqueue(payload_object: ScheduledTask.new(id, "drop_outstanding_reviews", due_at), priority: 1, run_at: time_in_min)
    expect(Delayed::Job.count).to eq(2)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_outstanding_reviews")
  end
end

deadline_reminder_email_type = 'Metareview deadline reminder email'
send_reminder_is_condition = 'is able to send reminder email for Metareview deadline to reviewers '
deadlne_type = "deadline_type: metareview"
display_deadline = "metareview"
expect_deadline_check(deadline_reminder_email_type, send_reminder_is_condition, deadlne_type, display_deadline)

deadline_reminder_email_type = 'Drop Topic deadline reminder email'
send_reminder_is_condition = 'is able to send reminder email for drop topic deadline to reviewers '
deadlne_type = "deadline_type: drop_topic"
display_deadline = "drop_topic"
expect_deadline_check(deadline_reminder_email_type, send_reminder_is_condition, deadlne_type, display_deadline)


deadline_reminder_email_type = 'Signup deadline reminder email'
send_reminder_is_condition = 'is able to send reminder email for signup deadline to reviewers '
deadlne_type = "deadline_type: signup"
display_deadline = "signup"
expect_deadline_check(deadline_reminder_email_type, send_reminder_is_condition, deadlne_type, display_deadline)


describe 'Team formation deadline reminder email' do
  it 'is able to send reminder email for team formation deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.current.advance(minutes: +2)

    due_at1 = Time.zone.parse(due_at.to_s(:db))
    curr_time = DateTime.current.to_s(:db)
    curr_time = Time.zone.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    dj = Delayed::Job.enqueue(payload_object: ScheduledTask.new(id, "team_formation", due_at), priority: 1, run_at: time_in_min)
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: team_formation")
    dj2 = Delayed::Job.enqueue(payload_object: ScheduledTask.new(id, "drop_one_member_topics", due_at), priority: 1, run_at: time_in_min)
    expect(Delayed::Job.count).to eq(2)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_one_member_topics")
  end
end
