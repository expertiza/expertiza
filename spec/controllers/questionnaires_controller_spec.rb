require 'rails_helper'

# Execute all tests in the context of the QuestionnairesController
describe QuestionnairesController do

  # Perform tests on the validate quiz method of the
  # questionnaires controller.
  describe 'Validate Quiz' do

    # Create a new controller instance for testing.
    before :each do
      @params = {
          :utf8 => '✓',
          :questionnaire => {
              :name => 'Quiz for test',
              :id => '',
              :type => 'QuizQuestionnaire'
          },
          :new_question => {
              '1' => 'Test Question 1'
          },
          :new_choices => {
              '1' => {
                  'MultipleChoiceRadio' => {
                      '1' => {
                          :iscorrect => '1',
                          :txt => 'Test Quiz 1'
                      },
                      '2' => {
                          :txt=> 'Test Quiz 2'
                      },
                      '3' => {
                          :txt=>'Test Quiz 3'
                      },
                      '4' => {
                          :txt => 'Test Quiz 4'
                      }
                  },
                  'MultipleChoiceCheckbox' => {
                      '1' => {
                          :iscorrect => '0',
                          :txt => ''
                      },
                      '2' => {
                          :iscorrect => '0',
                          :txt => ''
                      },
                      '3' => {
                          :iscorrect => '0',
                          :txt => ''
                      },
                      '4' => {
                          :iscorrect => '0',
                          :txt => ''
                      }
                  }
              }
          },
          :question_type => {
              '1' => {
                  :type => 'MultipleChoiceRadio'
              }
          },
          :save => 'Create Quiz',
          :aid => '1',
          :pid => '1',
          :controller => 'questionnaires',
          :action => 'create_quiz_questionnaire'
      }

      # Create an instructor
      @instructor = create(:instructor)

      #Create an assignment with quiz
      @assignment = create :assignment, require_quiz: true, instructor: @instructor, course: nil, num_quiz_questions: 1

      # Initialize controller
      @controller = QuestionnairesController.new
      allow(@controller).to receive(:params).and_return(@params)
    end

    # Verify a correct params hash representing a quiz
    # returns valid from validate_quiz.
    it 'should validate a correct submission' do

      # Call validate and expect to get valid back
      expect(@controller.validate_quiz).to eq 'valid'
    end
  end
end