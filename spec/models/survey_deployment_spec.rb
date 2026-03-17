# spec/models/survey_deployment_spec.rb
require 'rails_helper'

RSpec.describe SurveyDeployment, type: :model do
  let(:assgt_survey_questionnaire) { AssignmentSurveyQuestionnaire.new id: 99, name: 'assgt_survey', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1000 }
  let(:course_survey_questionnaire) { CourseSurveyQuestionnaire.new id: 98, name: 'course_survey', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1000 }
  let(:response_map) { build(:review_response_map, reviewer_id: 2) }
  describe 'validations' do
    it 'is invalid without a start_date' do
      survey_deployment = SurveyDeployment.new(end_date: Time.now + 1.day, questionnaire_id: 98, parent_id: 12112, type: 'CourseSurveyDeployment')
      expect(survey_deployment).not_to be_valid
      expect(survey_deployment.errors[:start_date]).to include("can't be blank")
    end

    it 'is invalid without an end_date' do
      survey_deployment = SurveyDeployment.new(start_date: Time.now, questionnaire_id: 98, parent_id: 12112, type: 'CourseSurveyDeployment')
      expect(survey_deployment).not_to be_valid
      expect(survey_deployment.errors[:end_date]).to include("can't be blank")
    end

    it 'is invalid when both start_date and end_date are nil' do
      survey_deployment = SurveyDeployment.new(questionnaire_id: 98, parent_id: 12112, type: 'CourseSurveyDeployment')
      expect(survey_deployment).not_to be_valid
      expect(survey_deployment.errors[:base]).to include('The start and end time should be specified.')
    end

    it 'is invalid if end_date is before start_date' do
      survey_deployment = SurveyDeployment.new(start_date: Time.now + 2.days, end_date: Time.now + 1.day, questionnaire_id: 98, parent_id: 12112, type: 'CourseSurveyDeployment')
      expect(survey_deployment).not_to be_valid
      expect(survey_deployment.errors[:base]).to include('The End Date should be after the Start Date.')
    end

    it 'is invalid if end_date is in the past' do
      survey_deployment = SurveyDeployment.new(start_date: Time.now - 1.day, end_date: Time.now - 1.hour, questionnaire_id: 98, parent_id: 12112, type: 'CourseSurveyDeployment')
      expect(survey_deployment).not_to be_valid
      expect(survey_deployment.errors[:base]).to include('The End Date should be in the future.')
    end

    it 'is valid with correct start_date and end_date' do
      survey_deployment = SurveyDeployment.new(start_date: Time.now, end_date: Time.now + 1.day, questionnaire_id: 98, parent_id: 12112, type: 'CourseSurveyDeployment')
      expect(survey_deployment).to be_valid
    end

    it 'is valid when start_date and end_date are the same' do
      now = Time.now
      survey_deployment = SurveyDeployment.new(start_date: Time.now + 1.day, end_date: Time.now + 1.day, questionnaire_id: 98, parent_id: 12112, type: 'CourseSurveyDeployment')
      expect(survey_deployment).to be_valid
    end

  end

  describe 'abstract methods' do
    let(:survey_deployment) { SurveyDeployment.new(start_date: Time.now, end_date: Time.now + 1.day) }

    it 'responds to parent_name' do
      expect { survey_deployment.parent_name }.not_to raise_error
    end

    it 'responds to response_maps' do
      expect { survey_deployment.response_maps }.not_to raise_error
    end

    it 'should return the associated response map' do
      survey_deployment = AssignmentSurveyDeployment.new(questionnaire_id: 986, start_date: Time.now - 1.day, end_date: nil, parent_id: '12345678', type: 'AssignmentSurveyDeployment', id: 1)
      allow(AssignmentSurveyResponseMap).to receive(:where).with(reviewee_id: 1).and_return([response_map])
      expect(survey_deployment.response_maps).to eq([response_map])
    end
  end
end
