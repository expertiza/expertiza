require 'rails_helper'

def test5(val)
  if val.eql? 'Submission deadline reminder email'
    val1 = 'is able to send reminder email for submission deadline to signed-up users '
    val2 = "submission"
  end
  if val.eql? 'Review deadline reminder email'
    val1 = 'is able to send reminder email for review deadline to reviewers '
    val2 = "review"
  end
  if val.eql? 'Metareview deadline reminder email'
    val1 = 'is able to send reminder email for Metareview deadline to reviewers '
    val2 = "metareview"
  end
  if val.eql? 'Drop Topic deadline reminder email'
    val1 = 'is able to send reminder email for drop topic deadline to reviewers '
    val2 = "drop_topic"
  end
  if val.eql? 'Signup deadline reminder email'
    val1 = 'is able to send reminder email for signup deadline to reviewers '
    val2 = "signup"
  end
  if val.eql? 'Team formation deadline reminder email'
    val1 = 'is able to send reminder email for team formation deadline to reviewers '
    val2 = "team_formation"
  end
  describe val do
    it val1 do
      @name = "user"
      due_at = DateTime.now.getlocal.advance(minutes: +2)
      due_at1 = Time.parse.getlocal(due_at.to_s(:db))
      curr_time = DateTime.now.getlocal.to_s(:db)
      # curr_time = Time.parse.getlocal(curr_time)
      Delayed::Job.delete_all
      expect(Delayed::Job.count).to eq(0)
      expect(Delayed::Job.count).to eq(1)
      expect(Delayed::Job.last.handler).to include("deadline_type: " + val2)
    end
  end
end
test5('Submission deadline reminder email')
test5('Review deadline reminder email')
test5('Metareview deadline reminder email')
test5('Drop Topic deadline reminder email')
test5('Signup deadline reminder email')
test5('Team formation deadline reminder email')
