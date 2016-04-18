require 'rails_helper'

# Execute all tests in the context of the QuestionnairesController
describe QuestionnairesController do

  # Perform tests on the validate quiz method of the
  # questionnaires controller.
  describe 'Validate Quiz' do

    # Create a new controller instance for testing.
    before :each do

      # Create an instructor
      @instructor = create(:instructor)

      #Create an assignment with quiz
      @assignment = create :assignment, require_quiz: true, instructor: @instructor, course: nil, num_quiz_questions: 1

      # Create a participant and assignment team
      @submitter = create :participant, assignment: @assignment
      @team = create :assignment_team, assignment: @assignment
      create :team_user, team: @team, user: @submitter.user

      # Define needed hash methods to emulate params.
      class Hash
        def require key
          return self[key]
        end
        def permit *args
          return self
        end
      end

      # Create a params stub for the controller to work with
      @params = {
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
          :aid => @assignment.id,
          :pid => '1',
          :controller => 'questionnaires',
          :action => 'create_quiz_questionnaire'
      }

      # Initialize controller and stub params
      @controller = QuestionnairesController.new
      allow(@controller).to receive(:params).and_return(@params)
    end

    it 'does not validate if the quiz does not have a name' do
      # Remove quiz name from params
      @params[:questionnaire][:name] = ''

      # Verify the quiz does not validate
      expect(@controller.validate_quiz).to eq 'Please specify quiz name (please do not use your name or id).'
    end

    it 'does not validate if a question does not have a type' do
      # Remove a question's type
      @params[:question_type]['1'][:type] = nil

      # Verify the quiz does not validate
      expect(@controller.validate_quiz).to eq 'Please select a type for each question'
    end

    it 'does not validate if a question does not have text' do
      # Delete a question's text
      @params[:new_question]['1'] = ''

      # Verify the quiz does not validate
      expect(@controller.validate_quiz).to eq 'Please make sure all questions have text'
    end

    it 'does not validate if a question options does not have text' do
      # Delete a question options's text
      @params[:new_choices]['1']['MultipleChoiceRadio']['1'][:txt] = ''

      # Verify the quiz does not validate
      expect(@controller.validate_quiz).to eq 'Please make sure every question has text for all options'
    end

    it 'does not validate if a question does not have a correct option' do
      # Remove the correct option
      @params[:new_choices]['1']['MultipleChoiceRadio']['1'][:iscorrect] = nil

      # Verify the quiz does not validate
      expect(@controller.validate_quiz).to eq 'Please select a correct answer for all questions'
    end

    # Verify a correct params hash representing a quiz
    # returns valid from validate_quiz.
    it 'should validate a correct submission' do

      # Call validate and expect to get valid back
      quiz = @controller.validate_quiz
      expect(quiz).to be_a QuizQuestionnaire
      expect(quiz.valid?).to be true
    end
  end
end