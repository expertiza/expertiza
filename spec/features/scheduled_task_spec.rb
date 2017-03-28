require 'rails_helper'
def enqueue_scheduled_tasks(stage)
  # due_at = DateTime.now.in_time_zone + 120
  # seconds_until_due = due_at - Time.now
  # minutes_until_due = seconds_until_due / 60
  # id = 2
  # @name = "user"
  due_at = DateTime.now.in_time_zone + 1.day
  # puts DateTime.now.in_time_zone
  # puts due_at
  due_at1 = Time.zone.parse(due_at.to_s(:db))
  curr_time = DateTime.now.in_time_zone.to_s(:db)
  curr_time = Time.zone.parse(curr_time)
  time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
  Delayed::Job.delete_all
  expect(Delayed::Job.count).to eq(0)
  Delayed::Job.enqueue(payload_object: ScheduledTask.new(id, stage, due_at), priority: 1, run_at: time_in_min)
end

describe 'Submission deadline reminder email' do
  it 'is able to send reminder email for submission deadline to signed-up users ' do
    # Delayed::Worker.delay_jobs = false
    # id = 2
    # @name = "user"
    enqueue_scheduled_tasks("submission")
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: submission")
  end
end

describe 'Review deadline reminder email' do
  it 'is able to send reminder email for review deadline to reviewers ' do
    # id = 2
    # @name = "user"
    enqueue_scheduled_tasks("drop_outstanding_reviews")
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_outstanding_reviews")
  end
end

describe 'Metareview deadline reminder email' do
  it 'is able to send reminder email for Metareview deadline to reviewers ' do
    # id = 2
    # @name = "user"
    enqueue_scheduled_tasks("metareview")
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: metareview")
  end
end

describe 'Drop Topic deadline reminder email' do
  it 'is able to send reminder email for drop topic deadline to reviewers ' do
    # id = 2
    # @name = "user"
    enqueue_scheduled_tasks("drop_topic")
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_topic")
  end
end

describe 'Signup deadline reminder email' do
  it 'is able to send reminder email for signup deadline to reviewers ' do
    # id = 2
    # @name = "user"
    enqueue_scheduled_tasks("signup")
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: signup")
  end
end

describe 'Team formation deadline reminder email' do
  it 'is able to send reminder email for team formation deadline to reviewers ' do
    # id = 2
    # @name = "user"
    enqueue_scheduled_tasks("team_formation")
    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: team_formation")
    due_at = DateTime.now.in_time_zone + 1.day
    due_at1 = Time.zone.parse(due_at.to_s(:db))
    curr_time = DateTime.now.in_time_zone.to_s(:db)
    curr_time = Time.zone.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.enqueue(payload_object: ScheduledTask.new(2, "drop_one_member_topics", due_at), priority: 1, run_at: time_in_min)
    expect(Delayed::Job.count).to eq(2)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_one_member_topics")
  end
end
