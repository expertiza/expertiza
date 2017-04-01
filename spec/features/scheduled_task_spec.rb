require 'rails_helper'

def get_time_to_run()
  due_at = DateTime.now.in_time_zone + 1.day
  due_at1 = Time.zone.parse(due_at.to_s(:db))
  curr_time = DateTime.now.in_time_zone.to_s(:db)
  curr_time = Time.zone.parse(curr_time)
  ((due_at1 - curr_time).to_i / 60) * 60
end

def enqueue_scheduled_tasks(stage)
  id = 2
  Delayed::Job.delete_all
  expect(Delayed::Job.count).to eq(0)
  Delayed::Job.enqueue(payload_object: ScheduledTask.new(id, stage, DateTime.now.in_time_zone + 1.day), priority: 1, run_at: get_time_to_run)
end

def send_reminder_email(email_type)
  enqueue_scheduled_tasks(email_type)
  expect(Delayed::Job.count).to eq(1)
  expect(Delayed::Job.last.handler).to include("deadline_type: " + email_type)
end

describe 'Submission deadline reminder email' do
  it 'is able to send reminder email for submission deadline to signed-up users ' do
    send_reminder_email("submission")
  end
end

describe 'Review deadline reminder email' do
  it 'is able to send reminder email for review deadline to reviewers ' do
    send_reminder_email("drop_outstanding_reviews")
  end
end

describe 'Metareview deadline reminder email' do
  it 'is able to send reminder email for Metareview deadline to reviewers ' do
    send_reminder_email("metareview")
  end
end

describe 'Drop Topic deadline reminder email' do
  it 'is able to send reminder email for drop topic deadline to reviewers ' do
    send_reminder_email("drop_topic")
  end
end

describe 'Signup deadline reminder email' do
  it 'is able to send reminder email for signup deadline to reviewers ' do
    send_reminder_email("signup")
  end
end

describe 'Team formation deadline reminder email' do
  it 'is able to send reminder email for team formation deadline to reviewers ' do
    send_reminder_email("team_formation")
    due_at = DateTime.now.in_time_zone + 1.day
    Delayed::Job.enqueue(payload_object: ScheduledTask.new(2, "drop_one_member_topics", due_at), priority: 1, run_at: get_time_to_run)
    expect(Delayed::Job.count).to eq(2)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_one_member_topics")
  end
end
