require 'rails_helper'

describe 'Reminder email' do

  before :all do
    @id = 2

    @due_at = DateTime.now.advance(minutes: +2)
    @due_at_parsed = Time.parse(@due_at.to_s(:db))
    current_time_parsed = Time.parse(DateTime.now.to_s(:db))

    @time_duration = ((@due_at_parsed - current_time_parsed).to_i / 60) * 60

    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)
  end

  it 'is able to send reminder email for submission deadline to signed-up users ' do
    Delayed::Job.enqueue(payload_object: DelayedMailer.new(@id, "submission", @due_at), priority: 1, run_at: @time_duration)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: submission")
  end

  it 'is able to send reminder email for review deadline to reviewers ' do
    Delayed::Job.enqueue(payload_object: DelayedMailer.new(@id, "review", @due_at), priority: 1, run_at: @time_duration)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: review")
  end

  it 'is able to send reminder email for Metareview deadline to reviewers ' do
    Delayed::Job.enqueue(payload_object: DelayedMailer.new(@id, "metareview", @due_at), priority: 1, run_at: @time_duration)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: metareview")
  end

  it 'is able to send reminder email for drop topic deadline to reviewers ' do
    Delayed::Job.enqueue(payload_object: DelayedMailer.new(@id, "drop_topic", @due_at), priority: 1, run_at: @time_duration)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_topic")
  end

  it 'is able to send reminder email for signup deadline to reviewers ' do
    Delayed::Job.enqueue(payload_object: DelayedMailer.new(@id, "signup", @due_at), priority: 1, run_at: @time_duration)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: signup")
  end

  it 'is able to send reminder email for team formation deadline to reviewers ' do
    Delayed::Job.enqueue(payload_object: DelayedMailer.new(@id, "team_formation", @due_at), priority: 1, run_at: @time_duration)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: team_formation")
  end

end