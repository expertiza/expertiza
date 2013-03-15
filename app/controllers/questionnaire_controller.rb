class QuestionnaireController < ApplicationController
  # Controller for Questionnaire objects
  # A Questionnaire can be of several types (QuestionnaireType)
  # Each Questionnaire contains zero or more questions (Question)
  # Generally a questionnaire is associated with an assignment (Assignment)  
  before_filter :authorize


  # determines whether the user is a ta or instructor
  # returns the instructors id, or the id of the ta's instructor
  def getInstructorId
    (session[:user]).role.name != 'Teaching Assistant' ? session[:user].id : Ta.get_my_instructor((session[:user]).id)
  end



  # Create a clone of the given questionnaire, copying all associated
  # questions. The name and creator are updated.
  def copy
    orig_questionnaire = Questionnaire.find(params[:id])
    questions = Question.find_all_by_questionnaire_id(params[:id])
    @questionnaire = orig_questionnaire.clone
    @questionnaire.instructor_id = getInstructorId
    @questionnaire.name = 'Copy of '+orig_questionnaire.name

    cloneQuestionnaireDetails(questions)
  end


  # clones the contents of a questionnaire, including the questions and associated advice
  def cloneQuestionnaireDetails(questions)
    begin
      @questionnaire.save!
      @questionnaire.update_attribute('created_at', Time.now)

      questions.each { |question|

        newquestion = question.clone
        newquestion.questionnaire_id = @questionnaire.id
        newquestion.save

        advice = QuestionAdvice.find_by_question_id(question.id)
        unless advice.nil?
          newadvice = advice.clone
          newadvice.question_id = newquestion.id
          newadvice.save
        end

        if @questionnaire.section == "Custom"
          old_question_type = QuestionType.find_by_question_id(question.id)
          unless old_question_type.nil?
            new_question_type = old_question_type.clone
            new_question_type.question_id = newquestion.id
            new_question_type.save
          end
        end
      }
      pFolder = TreeFolder.find_by_name(@questionnaire.display_type)
      parent = FolderNode.find_by_node_object_id(pFolder.id)
      if QuestionnaireNode.find_by_parent_id_and_node_object_id(parent.id, @questionnaire.id) == nil
        QuestionnaireNode.create(:parent_id => parent.id, :node_object_id => @questionnaire.id)
      end
      redirect_to :controller => 'questionnaire', :action => 'view', :id => @questionnaire.id
    rescue
      flash[:error] = 'The questionnaire was not able to be copied. Please check the original course for missing information.'+$!
      redirect_to :action => 'list', :controller => 'tree_display'
    end
  end

  # Remove a given questionnaire
  def delete

    @questionnaire = Questionnaire.find(params[:id])

    if @questionnaire
       begin
          name = @questionnaire.name

          for question in @questionnaire.questions
            current_q_type = QuestionType.find_by_question_id(question.id)
            unless current_q_type.nil?
              current_q_type.delete
            end
          end
          @questionnaire.delete
          flash[:note] = "Questionnaire <B>#{name}</B> was deleted."
      rescue
          flash[:error] = $!
      end
    end

    redirect_to :action => 'list', :controller => 'tree_display'
  end

  # View a questionnaire
  def view
    @questionnaire = Questionnaire.find(params[:id])
  end

  # Edit a questionnaire
  def edit

    begin
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to :action => 'list' if @questionnaire == nil

    if params['save']
      @questionnaire.update_attributes(params[:questionnaire])
      save
    end

    export if params['export']

    import if params['import']

    if params['view_advice']
        flash[:id] = params[:id]
        redirect_to :action => 'edit_advice'
    end
    rescue
      flash[:error] = $!
    end
  end

  def export
    @questionnaire = Questionnaire.find(params[:id])

    csv_data = QuestionnaireHelper::create_questionnaire_csv @questionnaire, session[:user].name

    send_data csv_data,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=questionnaires.csv"
  end



  def import
    @questionnaire = Questionnaire.find(params[:id])

    file = params['csv']
    questions = QuestionnaireHelper::get_questions_from_csv(@questionnaire, file)

    if questions != nil and questions.length > 0

      # delete the existing questions if no scores have been recorded yet
      @questionnaire.questions.each {
          | question |
        raise "Cannot import new questions, scores exist" if Score.find_by_question_id(question.id)
        question.delete
      }

      @questionnaire.questions = questions
    end
  end


  # Define a new questionnaire
  def new
    @questionnaire = Object.const_get(params[:model]).new
    @questionnaire.private = params[:private]
    @questionnaire.min_question_score = Questionnaire::DEFAULT_MIN_QUESTION_SCORE
    @questionnaire.max_question_score = Questionnaire::DEFAULT_MAX_QUESTION_SCORE
    @questionnaire.instruction_loc = Questionnaire::DEFAULT_QUESTIONNAIRE_URL
    @questionnaire.section = "Regular"
  end

  def select_questionnaire_type
    @questionnaire = Object.const_get(params[:questionnaire][:type]).new(params[:questionnaire])
    @questionnaire.private = params[:questionnaire][:private]
    @questionnaire.min_question_score = params[:questionnaire][:min_question_score]
    @questionnaire.max_question_score = params[:questionnaire][:max_question_score]
    @questionnaire.section = params[:questionnaire][:section]
    @questionnaire.id = params[:questionnaire][:id]
    @questionnaire.display_type = params[:questionnaire][:display_type]
  end

  # Save the new questionnaire to the database
  def create
    @questionnaire = Object.const_get(params[:questionnaire][:type]).new(params[:questionnaire])
    if (session[:user]).role.name == "Teaching Assistant"
      @questionnaire.instructor_id = Ta.get_my_instructor((session[:user]).id)
    else
      @questionnaire.instructor_id = session[:user].id
    end
    save
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def edit_advice
    redirect_to :controller => 'advice', :action => 'edit_advice'
  end

  def save_advice
    redirect_to :controller => 'advice', :action => 'save_advice'
  end

  # Toggle the access permission for this assignment from public to private, or vice versa
  def toggle_access
    questionnaire = Questionnaire.find(params[:id])
    questionnaire.private = !questionnaire.private
    questionnaire.save

    redirect_to :controller => 'tree_display', :action => 'list'
  end

  private
  #save questionnaire object after create or edit
  def save
    begin
      @questionnaire.save!
      save_questions @questionnaire.id if @questionnaire.id != nil and @questionnaire.id > 0
      pFolder = TreeFolder.find_by_name(@questionnaire.display_type)
      parent = FolderNode.find_by_node_object_id(pFolder.id)
      if QuestionnaireNode.find_by_parent_id_and_node_object_id(parent.id,@questionnaire.id) == nil
        QuestionnaireNode.create(:parent_id => parent.id, :node_object_id => @questionnaire.id)
      end
    rescue
      flash[:error] = $!
    end
  end

  #save parameters for new questions
  def save_new_question_parameters(qid, q_num)
    q = QuestionType.new
    q.q_type = params[:question_type][q_num][:type]
    q.parameters = params[:question_type][q_num][:parameters]
    q.question_id =  qid
    q.save
  end

  # save questions that have been added to a questionnaire
  def save_new_questions(questionnaire_id)

    if params[:new_question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for question_key in params[:new_question].keys
        q = Question.new(params[:new_question][question_key])
        q.questionnaire_id = questionnaire_id
        if q.true_false == ''
          q.true_false = false
        end
        unless q.txt.strip.empty?
          q.save
          questionnaire = Questionnaire.find_by_id(questionnaire_id)
          if questionnaire.section == "Custom"
            for i in (questionnaire.min_question_score .. questionnaire.max_question_score)
              a = QuestionAdvice.new(:score => i, :advice => nil)
              a.question_id = q.id
              a.save
            end
            save_new_question_parameters(q.id, question_key)
          end

        end
      end
    end
  end

  # delete questions from a questionnaire
  # @param [Object] questionnaire_id
  def delete_questions(questionnaire_id)
    # Deletes any questions that, as a result of the edit, are no longer in the questionnaire
    questions = Question.find(:all, :conditions => "questionnaire_id = " + questionnaire_id.to_s)
    for question in questions
      should_delete = true
      for question_key in params[:question].keys
        if question_key.to_s === question.id.to_s
          should_delete = false
        end
      end
      if should_delete
        for advice in question.question_advices
          advice.destroy
        end
        if Questionnaire.find_by_id(questionnaire_id).section == "Custom"
            question_type = QuestionType.find_by_question_id(question.id)
            question_type.destroy
        end
        question.destroy
      end
    end
  end


  # @param [Object] question_type_key
  def update_question_type (question_type_key)
    this_q = QuestionType.find(question_type_key)
    this_q.parameters = params[:q][question_type_key][:parameters]
    if params[:q][question_type_key][:q_type] == "0"
        this_q.q_type =  Question::GRADING_TYPES_CUSTOM[0][0]
    elsif params[:q][question_type_key][:q_type] == "1"
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[1][0]
    elsif params[:q][question_type_key][:q_type] == "2"
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[2][0]
    elsif params[:q][question_type_key][:q_type] == "3"
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[3][0]
    elsif params[:q][question_type_key][:q_type] == "4"
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[4][0]
    else
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[5][0]
    end
    unless this_q.nil?
      this_q.save
    end
  end

  # Handles questions whose wording changed as a result of the edit
  # @param [Object] questionnaire_id
  def save_questions(questionnaire_id)
    delete_questions questionnaire_id
    save_new_questions questionnaire_id

    if params[:question]
      for question_key in params[:question].keys
        begin
          if params[:question][question_key][:txt].strip.empty?
            # question text is empty, delete the question
            if Questionnaire.find_by_id(questionnaire_id).section == "Custom"
              QuestionType.find_by_question_id(question_key).delete
            end
            Question.delete(question_key)
          else
            # Update existing question.
            Question.update(question_key, params[:question][question_key])
          end
        rescue ActiveRecord::RecordNotFound
          # ignored
        end
      end
      if Questionnaire.find_by_id(questionnaire_id).section == "Custom"
        for question_type_key in params[:q].keys
          update_question_type(question_type_key)
        end
      end
    end
  end
end
