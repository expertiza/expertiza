require 'rails_helper'
include LogInHelper

describe GithubContributorsController do
  before(:each) do
    student.save
    instructor.save
    @role = Role.new(name: 'Instructor')
    @role.save
    @instructor = User.find_by(name: 'instructor')
    @student = User.find_by(name: 'student')
    @assignment = Assignment.where(name: 'My assignment').first ||
        Assignment.new("name" => "My assignment", "instructor_id" => @instructor.id)
    @assignment.save
    @assignment_team = AssignmentTeam.where(name: 'My Github Team').first ||
        AssignmentTeam.new(name: 'My Github Team', parent_id: @assignment.id)
    @assignment_team.save
    @sub_record = SubmissionRecord.new(content: 'https://github.com/mozilla/geckodriver',
                                       operation: 'Submit Hyperlink',
                                       team_id: @assignment_team.id,
                                       user: @student.name,
                                       assignment_id: @assignment.id)
    @sub_record.save
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@instructor)
    allow_any_instance_of(ApplicationController).to receive(:current_role_name).and_return('Instructor')
    allow_any_instance_of(ApplicationController).to receive(:current_role).and_return(@role)
    allow(AssignmentTeam).to receive(:find).with(@assignment_team.id).and_return @assignment_team
    allow(Assignment).to receive(:find).with(@assignment.id).and_return @assignment
  end

  describe '#show_github_contributor' do
    let(:github_contributors_controller) { GithubContributorsController.new }
    it 'valid_submission' do
      update_submission_record(@sub_record, 'https://github.com/mozilla/geckodriver', 'Submit Hyperlink')
      expect(response).to have_http_status(200)
    end

    it 'invalid_submission#1' do
      update_submission_record(@sub_record, 'Some Random File.pdf', 'Submit File')
      expect(response).to redirect_to('/')
    end

    it 'invalid_submission#2' do
      update_submission_record(@sub_record, 'https://wikipedia.org', 'Submit Hyperlink')
      expect(response).to render_template('github_contributors/not_found')
    end

    it 'invalid_submission#3' do
      update_submission_record(@sub_record, 'https://github.com/ai-se/citemap', 'Submit Hyperlink')
      expect(response).to render_template('github_contributors/not_found')
    end
  end
end

def update_submission_record(submission_record, content, operation)
  submission_record.content = content
  submission_record.operation = operation
  submission_record.save
  get 'show', {id: @sub_record.id}
end