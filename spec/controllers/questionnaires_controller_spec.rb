extend RSpec::Matchers
require 'spec_helper'

describe QuestionnairesController do
  let(:questionnaire) { build(:questionnaire) }
  let(:quiz_questionnaire) { build(:questionnaire, type: 'QuizQuestionnaire') }
  let(:review_questionnaire) { build(:questionnaire, type: 'ReviewQuestionnaire') }
  let(:question) { build(:question, id: 1) }
  before(:each) do
    instructor = build(:instructor)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe '#copy,  #copy_questionnaire_details and #assign_instructor_id' do
    it 'redirects to view page of copied questionnaire' do
    end
  end

  describe '#view' do
    it 'renders questionnaires#view page' do
      questionnaires = double('Questionnaire')
      allow(Questionnaire).to receive(:find).and_return(questionnaires)
      params = {
        id: 11
      }
      get :view, params
      expect(response).to render_template(:view)
    end
  end

  describe '#new' do
    context 'when params[:model] has whitespace in it' do
      it 'creates new questionnaire object and renders questionnaires#new page' do
        params = {
          model: "ReviewQuestionnaire"
        }
        get :new, params
        expect(response).to render_template(:new)
      end
    end

    context 'when params[:model] does not have whitespace in it' do
      it 'creates new questionnaire object and renders questionnaires#new page' do
        params = {
          model: "Teammate ReviewQuestionnaire"
        }
        get :new, params
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#create' do
    it 'redirects to questionnaires#edit page after create a new questionnaire' do
      tree_folder1 = double('TreeFolder')
      allow(tree_folder1).to receive(:id).and_return(1)
      allow(tree_folder1).to receive(:node_object_id).and_return(1)
      tree_folder2 = double('TreeFolder')
      allow(tree_folder2).to receive(:id).and_return(1)
      allow(tree_folder2).to receive(:node_object_id).and_return(1)
      allow(TreeFolder).to receive(:where).with(["name like ?", "Review"]).and_return([tree_folder1, tree_folder2])
      folder_node2 = double('FolderNode')
      allow(folder_node2).to receive(:id).and_return(1)
      allow(FolderNode).to receive(:find_by_node_object_id).and_return(folder_node2)
      user = double("User")
      allow(user).to receive(:id).and_return(1)
      params = {
        questionnaire: {
          private: "true",
          type: "ReviewQuestionnaire",
          name: "Random Name",
          min_question_score: "0",
          max_question_score: "5"
        }
      }
      session = {user: user}
      get :create, params, session
      expect(flash[:success]).to eq("You have successfully created a questionnaire!")
      expect(response).to redirect_to(edit_questionnaire_path(id: 1))
    end
  end

  describe '#create_quiz_questionnaire, #create_questionnaire and #save' do
    context 'when quiz is valid' do
      context 'when questionnaire type is QuizQuestionnaire' do
        it 'redirects to submitted_content#edit page' do
          allow_any_instance_of(QuestionnairesController).to receive(:valid_quiz).and_return( "valid" )
          allow(Participant).to receive(:find).and_return(double("Participant"))

          bo = double("BasicObject")
          allow(bo).to receive(:id).and_return(1)

          allow(AssignmentTeam).to receive(:team).and_return(bo)

          user = double("User")
          allow(user).to receive(:id).and_return(1)
          params = {
            questionnaire: {
              type: "QuizQuestionnaire",
              name: "Random Name",
              min_question_score: "0",
              max_question_score: "5"
            },
            pid: 1
          }
          session = {user: user}
          get :create_quiz_questionnaire, params, session
          expect(response).to redirect_to controller: 'submitted_content', action: 'edit', id: 1
        end
      end

      context 'when questionnaire type is not QuizQuestionnaire' do
        it 'redirects to submitted_content#edit page' do
          allow_any_instance_of(QuestionnairesController).to receive(:valid_quiz).and_return( "valid" )
          allow(Participant).to receive(:find).and_return(double("Participant"))

          bo = double("BasicObject")
          allow(bo).to receive(:id).and_return(1)

          allow(AssignmentTeam).to receive(:team).and_return(bo)

          user = double("User")
          allow(user).to receive(:id).and_return(1)
          role_name = double("BasicObject")
          allow(role_name).to receive(:name).and_return("Teaching Assistant")
          allow(user).to receive(:role).and_return( role_name )

          allow(Ta).to receive(:get_my_instructor).and_return(1)

          tree_folder1 = double('TreeFolder')
          allow(tree_folder1).to receive(:id).and_return(1)
          allow(TreeFolder).to receive(:find_by_name).and_return(tree_folder1)

          folder_node2 = double('FolderNode')
          allow(folder_node2).to receive(:id).and_return(1)
          allow(FolderNode).to receive(:find_by_node_object_id).and_return(folder_node2)

          params = {
            questionnaire: {
              type: "ReviewQuestionnaire",
              name: "Random Name",
            },
            pid: 1
          }
          session = {user: user}
          get :create_quiz_questionnaire, params, session
          expect(response).to redirect_to controller: 'tree_display', action: 'list'
        end
      end
    end

    context 'when quiz is invalid and questionnaire type is QuizQuestionnaire' do
      it 'redirects to submitted_content#edit page' do# context is wrong as the method redirects back not to the page mentioned in context
        request.env["HTTP_REFERER"] = "where_i_came_from"
        allow_any_instance_of(QuestionnairesController).to receive(:valid_quiz).and_return( "invalid" )
        get :create_quiz_questionnaire
        expect(response).to redirect_to "where_i_came_from"
      end
    end
  end

  describe '#edit' do
    context 'when @questionnaire is not nil' do
      it 'renders the questionnaires#edit page' do
        allow(Questionnaire).to receive(:find_by_id).and_return(double('Questionnaire'))
        params = {
            id: 1
        }
        get :edit, params
        expect(response).to render_template(:edit)
      end
    end

    context 'when @questionnaire is nil' do
      it 'redirects to /questionnaires page' do
        params = {
            id: -1
        }
        get :edit, params
        expect(response).to redirect_to Questionnaire
      end
    end
  end

  describe '#update' do
    context 'successfully updates the attributes of questionnaire' do
      it 'redirects to questionnaires#edit page after updating' do
      end
    end

    context 'have some errors when updating the attributes of questionnaire' do
      it 'redirects to questionnaires#edit page after updating'
    end
  end

  describe '#delete' do
    context 'when @questionnaire.assignments returns non-empty array' do
      it 'sends the error message to flash[:error]'
    end

    context 'when question.answers returns non-empty array' do
      it 'sends the error message to flash[:error]'
    end

    context 'when @questionnaire.assignments and question.answers return empty arrays' do
      it 'deletes all objects related to current questionnaire'
    end
  end

  describe '#toggle_access' do
    it 'redirects to tree_display#list page' do
      allow(Questionnaire).to receive(:find).and_return(questionnaire)
      params = {
            id: 1
        }
        user = double("User")
        allow(user).to receive(:id).and_return(1)
        session = {user: user}
      get :toggle_access, params, session
      expect(response).to redirect_to controller: 'tree_display', action: 'list'
    end
  end

  describe '#add_new_questions' do
    context 'when adding ScoredQuestion' do
      it 'redirects to questionnaires#edit page after adding new questions'
    end

    context 'when adding unScoredQuestion' do
      it 'redirects to questionnaires#edit page after adding new questions'
    end
  end

  describe '#save_all_questions' do
    context 'when params[:save] is not nil, params[:view_advice] is nil' do
      it 'redirects to questionnaires#edit page after saving all questions'
        # params = {
        #   id: 1,
        #   save: true,
        #   question: {
        #     '1' => {
        #       seq: 66.0,
        #       txt: 'WOW',
        #       weight: 10,
        #       size: '50,3',
        #       max_label: 'Strong agree',
        #       min_label: 'Not agree'
        #     }
        #   }
        # }
    end

    context 'when params[:save] is nil, params[:view_advice] is not nil' do
      it 'redirects to advice#edit_advice page'
    end
  end

  describe '#view_quiz' do
    it 'renders questionnaires#view_quiz' do
      allow(Questionnaire).to receive(:find).and_return(questionnaire)
      allow(Participant).to receive(:find).and_return(double('Participant'))
      params = {
          id: 1,
          pid: 1
        }
        get :view_quiz, params
        expect(response).to render_template(:view)
    end
  end

  describe '#new_quiz' do
    context 'when an assignment requires quiz' do
      it 'renders questionnaires#new_quiz if current participant has a team'

      it 'shows error message and redirects to submitted_content#view if current participant does not have a team' do
        assignment= double('Assignment')
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(assignment).to receive(:require_quiz?).and_return(true)
        dummy = double('BasicObject')
        allow(AssignmentParticipant).to receive(:find).and_return(dummy)
        team = double('AssignmentParticipant')
        allow(dummy).to receive(:team).and_return(team)
        allow(team).to receive(:nil?).and_return(true)
        params = {
            id: 1,
            pid: 1
        }
        get :new_quiz, params
        expect(flash[:error]).to eq("You should create or join a team first.")
        expect(response).to redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
      end


      it 'shows error message and redirects to submitted_content#view if current participant have a team w/o topic' do
        assignment= double('Assignment')
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(assignment).to receive(:require_quiz?).and_return(true)
        dummy = double('BasicObject')
        allow(AssignmentParticipant).to receive(:find).and_return(dummy)
        team = double('AssignmentParticipant')
        allow(dummy).to receive(:team).and_return(team)
        allow(team).to receive(:nil?).and_return(false)
        allow(assignment).to receive(:has_topics?).and_return(true)
        allow(team).to receive(:topic).and_return(dummy)
        allow(dummy).to receive(:nil?).and_return(true)
        params = {
            id: 1,
            pid: 1
        }
        get :new_quiz, params
        expect(flash[:error]).to eq("Your team should have a topic.")
        expect(response).to redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
      end
    end

    context 'when an assignment does not require quiz' do
      it 'shows error message and redirects to submitted_content#view'do
        assignment= double('Assignment')
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(assignment).to receive(:require_quiz?).and_return(false)
        params = {
            id: 1,
            pid: 1
        }
        get :new_quiz, params
        expect(flash[:error]).to eq("This assignment does not support the quizzing feature.")
        expect(response).to redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
      end
    end
  end

  describe '#edit_quiz' do
    context 'when current questionnaire is not taken by anyone' do
      it 'renders questionnaires#edit page' do
        questionnaire= double('Questionnaire')
        allow(Questionnaire).to receive(:find).and_return(questionnaire)
        allow(questionnaire).to receive(:taken_by_anyone?).and_return(false)
        params = {
            id: 1
        }
        get :edit_quiz, params
        expect(response).to render_template(:edit)
      end
    end

    context 'when current questionnaire has been taken by someone' do
      it 'shows flash[:error] message and redirects to submitted_content#view page' do
        questionnaire= double('Questionnaire')
        allow(Questionnaire).to receive(:find).and_return(questionnaire)
        allow(questionnaire).to receive(:taken_by_anyone?).and_return(true)
        params = {
            id: 1,
            pid: 1
        }
        get :edit_quiz, params
        expect(flash[:error]).to eq("Your quiz has been taken by some other students, you cannot edit it anymore.")
        expect(response).to redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
      end
    end
  end

  describe '#update_quiz' do
    context 'when @questionnaire is nil' do
      it 'redirects to submitted_content#view page' do
        params = {
          id: 1,
          pid: 1
        }
        get :update_quiz, params
        expect(response).to redirect_to(view_submitted_content_index_path(id: params[:pid]))
      end
    end

    context 'when @questionnaire is not nil' do
      it 'updates all quiz questions and redirects to submitted_content#view page' do
        params = {
          id: 3,
          pid: 1,
          save: true,
          questionnaire: {
            name: 'test questionnaire',
            instructor_id: 6,
            private: 0,
            min_question_score: 0,
            max_question_score: 5,
            type: 'ReviewQuestionnaire',
            display_type: 'Review',
            instructor_loc: ''
          },
          question: {
            '1' => {txt: 'Q1'},
            '2' => {txt: 'Q2'},
            '3' => {txt: 'Q3'}
          },
          quiz_question_choices: {
            '1' => {MultipleChoiceRadio:
                    {:correctindex => 1, '1' => {txt: 'a11'}, '2' => {txt: 'a12'}, '3' => {txt: 'a13'}, '4' => {txt: 'a14'}}},
            '2' => {TrueFalse: {'1' => {iscorrect: 'True'}}},
            '3' => {MultipleChoiceCheckbox:
                    {'1' => {iscorrect: '1', txt: 'a31'}, '2' => {iscorrect: '0', txt: 'a32'},
                     '3' => {iscorrect: '1', txt: 'a33'}, '4' => {iscorrect: '0', txt: 'a34'}}}
          }
        }
        get :update_quiz, params
        expect(response).to redirect_to(view_submitted_content_index_path(id: params[:pid]))
      end
    end
  end

  describe '#valid_quiz' do
    context 'when user does not specify quiz name' do
      it 'returns message (Please specify quiz name (please do not use your name or id).)' do
        assignment = double('Assignment')
        allow(assignment).to receive(:num_quiz_questions).and_return(1)
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(subject).to receive(:params).and_return({
          aid: 1,
          questionnaire: { name: ""}
        })
        expect(subject.valid_quiz).to eq("Please specify quiz name (please do not use your name or id).")
      end
    end

    context 'when user does not specify a type for each question' do
      it 'returns message (Please select a type for each question)' do
        assignment = double('Assignment')
        allow(assignment).to receive(:num_quiz_questions).and_return(1)
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(subject).to receive(:params).and_return({
          aid: 1,
          questionnaire: { name: "Random Name"}
        })
        expect(subject.valid_quiz).to eq("Please select a type for each question")
      end
    end

    context 'when user does not specify choice info for one question' do
      it 'returns mesage (Please select a correct answer for all questions)' do
        assignment = double('Assignment')
        allow(assignment).to receive(:num_quiz_questions).and_return(1)
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(subject).to receive(:params).and_return({
           aid: 1,
           questionnaire: {name: 'test questionnaire'},
           question_type: {'1' => {type: 'TrueFalse'}},
           new_question: {'1' => {iscorrect: 'True'}},
           new_choices: {'1' => {'TrueFalse' => nil}}
         })
        expect(subject.valid_quiz).to eq("Please select a correct answer for all questions")
      end
    end

    context 'when user specifies all necessary information' do
      it 'returns mesage (valid)' do
        # controller.params = {
        #   aid: 1,
        #   questionnaire: {name: 'test questionnaire'},
        #   question_type: {'1' => {type: 'TrueFalse'}},
        #   new_question: {'1' => {iscorrect: 'True'}},
        #   new_choices: {'1' => {'TrueFalse' => 'sth'}}
        # }
        assignment = double('Assignment')
        allow(assignment).to receive(:num_quiz_questions).and_return(1)
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(subject).to receive(:params).and_return({
           aid: 1,
           questionnaire: {name: 'test questionnaire'},
           question_type: {'1' => {type: 'TrueFalse'}},
           new_question: {'1' => {iscorrect: 'True'}},
           new_choices: {'1' => {'TrueFalse' => {0 => {txt:'sth', iscorrect: 0}}}}
         })
        expect(subject.valid_quiz).to eq("valid")
      end
    end
  end

  describe '#save_choices' do
    it 'is able to save different kinds of quiz questions' do

      controller.params = {
         new_question: {'1' => 'q1', '2' => 'q2', '3' => 'q3'},
         new_choices:
         {'1' =>
           {MultipleChoiceRadio: {'1' => {txt: 'a11', iscorrect: '3'}, '2' => {txt: 'a12'}, '3' => {txt: 'a13'}, '4' => {txt: 'a14'}}},
          '2' =>
           {TrueFalse: {'1' => {iscorrect: '1'}}},
          '3' =>
           {MultipleChoiceCheckbox:
             {'1' => {iscorrect: '1', txt: 'a31'},
              '2' => {iscorrect: '0', txt: 'a32'},
              '3' => {iscorrect: '1', txt: 'a33'},
              '4' => {iscorrect: '0', txt: 'a34'}}}},
         question_type: {'1' => {type: 'MultipleChoiceRadio'}, '2' => {type: 'TrueFalse'}, '3' => {type: 'MultipleChoiceCheckbox'}}
      }
      #allow(Question).to receive(:where).and_return([question,question])
      #get :save_choices, controller.params
      #allow(QuestionnairesController).to receive(:params).with(:id => "1").and_return(true)
      #@save_questions = QuestionnairesController.new
      #@save_questions.send(:save_all_questions_questionnaires_path).should == true
    end
  end
end
