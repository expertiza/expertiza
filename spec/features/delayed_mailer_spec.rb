require 'rails_helper'

describe 'Submission deadline reminder email' do
  it 'is able to send reminder email for submission deadline to signed-up users ' do
    # Delayed::Worker.delay_jobs = false
    id = 2
    @name = "user"

    # due_at = DateTime.now.in_time_zone + 120
    # seconds_until_due = due_at - Time.now
    # minutes_until_due = seconds_until_due / 60
    due_at = DateTime.now.in_time_zone + 2.minutes

    # puts DateTime.now.in_time_zone
    # puts due_at
    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.in_time_zone.to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    Delayed::Job.enqueue(payload_object: DelayedMailer.new(id, "submission", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)

    expect(Delayed::Job.last.handler).to include("deadline_type: submission")
  end
end

describe 'Review deadline reminder email' do
  it 'is able to send reminder email for review deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.in_time_zone + 2.minutes

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.in_time_zone.to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    Delayed::Job.enqueue(payload_object: DelayedMailer.new(id, "review", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: review")
  end
end

describe 'Metareview deadline reminder email' do
  it 'is able to send reminder email for Metareview deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.in_time_zone + 2.minutes

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.in_time_zone.to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    Delayed::Job.enqueue(payload_object: DelayedMailer.new(id, "metareview", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: metareview")
  end
end

describe 'Drop Topic deadline reminder email' do
  it 'is able to send reminder email for drop topic deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.in_time_zone + 2.minutes

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.in_time_zone.to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    Delayed::Job.enqueue(payload_object: DelayedMailer.new(id, "drop_topic", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: drop_topic")
  end
end

describe 'Signup deadline reminder email' do
  it 'is able to send reminder email for signup deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.in_time_zone + 2.minutes

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.in_time_zone.to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    Delayed::Job.enqueue(payload_object: DelayedMailer.new(id, "signup", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: signup")
  end
end

# Added by Prateek during Spring 2017 E1711
describe 'Team formation deadline reminder email' do
  it 'is able to send reminder email for team formation deadline to reviewers ' do
    id = 2
    @name = "user"
    due_at = DateTime.now.in_time_zone + 2.minutes

    due_at1 = Time.parse(due_at.to_s(:db))
    curr_time = DateTime.now.in_time_zone.to_s(:db)
    curr_time = Time.parse(curr_time)
    time_in_min = ((due_at1 - curr_time).to_i / 60) * 60
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)

    Delayed::Job.enqueue(payload_object: DelayedMailer.new(id, "team_formation", due_at), priority: 1, run_at: time_in_min)

    expect(Delayed::Job.count).to eq(1)
    expect(Delayed::Job.last.handler).to include("deadline_type: team_formation")
  end
end

describe DelayedMailer do
  describe ".find_team_members_email_for_all_topics" do
    it "gets user emails" do
      assignment = create(:assignment)
      sign_up_topic = create(:topic)
      user = create(:student)
      signed_up_team = create(:signed_up_team)
      team_user = create(:team_user)
      # deadline type and due_date are not important for this test
      dm = DelayedMailer.new(assignment.id, nil, nil)
      expect(dm.find_team_members_email_for_all_topics(sign_up_topic)).to eq(["expertiza@mailinator.com"])
    end
  end

  describe ".mail_signed_up_users" do
    it "sends emails to signed up users when no topics" do
      assignment = create(:assignment)
      dm = DelayedMailer.new(assignment.id,nil, nil)

      # Do not let these functions do anything, like sending out emails
      allow(DelayedMailer).to receive(:find_team_members_email).and_return(true)
      allow(DelayedMailer).to receive(:email_reminder).and_return(true)
      expect(dm).to receive(:find_team_members_email)
      expect(dm).to receive(:email_reminder)
      dm.mail_signed_up_users
    end
  end

  describe ".mail_signed_up_users" do
    it "sends emails to singed up users when there are topics" do
      assignment = create(:assignment)
      sign_up_topic = create(:topic)
      dm = DelayedMailer.new(assignment.id,nil, nil)

      # Do not let these functions do anything
      allow(DelayedMailer).to receive(:find_team_members_email_for_all_topics).and_return(true)
      allow(DelayedMailer).to receive(:email_reminder).and_return(true)
      expect(dm).to receive(:find_team_members_email_for_all_topics).with([sign_up_topic])
      expect(dm).to receive(:email_reminder)
      dm.mail_signed_up_users
    end
  end

  describe ".find_team_members_email" do
    it "gets emails of team members" do
      # deadline_type and due_date are not important for this test
      dm = DelayedMailer.new(1, nil, nil)
      user = create(:student)
      team = Team.create(parent_id: 1)
      team_user = create(:team_user, team_id: team.id, user_id: user.id)
      expect(dm.find_team_members_email).to eq(["expertiza@mailinator.com"])
    end
  end

end
