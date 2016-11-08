require 'rails_helper'

describe 'Submission deadline reminder email' do
  it 'is able to send reminder email for submission deadline to signed-up users ' do
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

    dj = Delayed::Job.enqueue(payload_object: ScheduledTask.new(id, "submission", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)

    expect(Delayed::Job.last.handler).to include("deadline_type: submission")
  end
end

describe 'Review deadline reminder email' do
  it 'is able to send reminder email for review deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.advance(minutes: +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.to_s(:db)
    curr_time = Time.parse(curr_time)
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

describe 'Metareview deadline reminder email' do
  it 'is able to send reminder email for Metareview deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.advance(minutes: +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    dj = Delayed::Job.enqueue(payload_object: ScheduledTask.new(id, "metareview", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: metareview")
  end
end

describe 'Drop Topic deadline reminder email' do
  it 'is able to send reminder email for drop topic deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.advance(minutes: +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    dj = Delayed::Job.enqueue(payload_object: ScheduledTask.new(id, "drop_topic", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_topic")
  end
end

describe 'Signup deadline reminder email' do
  it 'is able to send reminder email for signup deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.advance(minutes: +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    dj = Delayed::Job.enqueue(payload_object: ScheduledTask.new(id, "signup", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: signup")
  end
end

describe 'Team formation deadline reminder email' do
  it 'is able to send reminder email for team formation deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.advance(minutes: +2)

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.to_s(:db)
    curr_time = Time.parse(curr_time)
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
