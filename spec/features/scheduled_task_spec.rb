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

describe 'Review deadline reminder email' do
  it 'is able to send reminder email for review deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = Time.zone.now.advance(minutes: +2)

    due_at1 = Time.zone.parse(due_at.to_s(:db))
    curr_time = Time.zone.now.to_s(:db)
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

describe 'Metareview deadline reminder email' do
  it 'is able to send reminder email for Metareview deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = Time.zone.now.advance(minutes: +2)

    due_at1 = Time.zone.parse(due_at.to_s(:db))
    curr_time = Time.zone.now.to_s(:db)
    curr_time = Time.zone.parse(curr_time)
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
    due_at = Time.zone.now.advance(minutes: +2)

    due_at1 = Time.zone.parse(due_at.to_s(:db))
    curr_time = Time.zone.now.to_s(:db)
    curr_time = Time.zone.parse(curr_time)
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
    due_at = Time.zone.now.advance(minutes: +2)

    due_at1 = Time.zone.parse(due_at.to_s(:db))
    curr_time = Time.zone.now.to_s(:db)
    curr_time = Time.zone.parse(curr_time)
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
    due_at = Time.zone.now.advance(minutes: +2)

    due_at1 = Time.zone.parse(due_at.to_s(:db))
    curr_time = Time.zone.now.to_s(:db)
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
