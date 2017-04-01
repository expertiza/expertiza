require 'rails_helper'
require 'features/helpers/delayed_task_helper'
include DelayedTaskHelper

describe 'Submission deadline reminder email' do
  it 'is able to send reminder email for submission deadline to signed-up users ' do
    send_reminder_email("submission", 1.day)
  end
end

describe 'Review deadline reminder email' do
  it 'is able to send reminder email for review deadline to reviewers ' do
    send_reminder_email("drop_outstanding_reviews", 1.day)
  end
end

describe 'Metareview deadline reminder email' do
  it 'is able to send reminder email for Metareview deadline to reviewers ' do
    send_reminder_email("metareview", 1.day)
  end
end

describe 'Drop Topic deadline reminder email' do
  it 'is able to send reminder email for drop topic deadline to reviewers ' do
    send_reminder_email("drop_topic", 1.day)
  end
end

describe 'Signup deadline reminder email' do
  it 'is able to send reminder email for signup deadline to reviewers ' do
    send_reminder_email("signup", 1.day)
  end
end

describe 'Team formation deadline reminder email' do
  it 'is able to send reminder email for team formation deadline to reviewers ' do
    send_reminder_email("team_formation", 1.day)
    due_at = DateTime.now.in_time_zone + 1.day
    Delayed::Job.enqueue(payload_object: ScheduledTask.new(2, "drop_one_member_topics", due_at), priority: 1, run_at: time_to_run(1.day))
    expect(Delayed::Job.count).to eq(2)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_one_member_topics")
  end
end
