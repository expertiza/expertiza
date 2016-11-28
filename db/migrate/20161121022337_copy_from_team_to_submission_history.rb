class CopyFromTeamToSubmissionHistory < ActiveRecord::Migration
  def up
  	# team table - iterate
  	# submitted hyperlinks read
  	# for each hyperlink, create a new entry in the submission histories table
  	# for each file, create a new entry in the submission histories table
  	AssignmentTeam.for_each do |assignment_team|
  		assignment_team.hyperlinks.for_each do |hyperlink|
  			submission_history = SubmissionHistory.create(assignment_team, hyperlink, "add")
        submission_history.submitted_at = assignment_team.updated_at
        submission_history.save
  		end

      assignment_team.submitted_files.for_each do |file|
        submission_history = SubmissionHistory.create(assignment_team, file, "add")
        submission_history.submitted_at = File.mtime(file)
        submission_history.save
      end
  	end

  end
  def down
  	# find submission histories for each team
  	# for each entry, if it is a hyperlink, add to the submitted hyperlinks column
  	# if it is a file, chill..
    AssignmentTeam.for_each do |assignment_team|
      SubmissionHistory.where(team = assignment_team).for_each do |submission_history|
        if submission_history.is_a? LinkSubmissionHistory
          assignment_team.submit_hyperlink(submission_history.submitted_detail)
          assignment_team.save
        end
      end
    end
  end
end
