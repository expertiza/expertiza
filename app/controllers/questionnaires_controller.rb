class QuestionnairesController < ApplicationController
  # Controller for Questionnaire objects
  # A Questionnaire can be of several types (QuestionnaireType)
  # Each Questionnaire contains zero or more questions (Question)
  # Generally a questionnaire is associated with an assignment (Assignment)

  before_filter :authorize

  def action_allowed?
    ['Administrator',
     'Instructor',
     'Teaching Assistant','Student'].include? current_role_name
  end

  # Create a clone of the given questionnaire, copying all associated
  # questions. The name and creator are updated.
  def copy
    orig_questionnaire = Questionnaire.find(params[:id])
    questions = Question.where(questionnaire_id: params[:id])
    @questionnaire = orig_questionnaire.clone
    @questionnaire.instructor_id = session[:user].instructor_id  ## Why was TA-specific code removed here?  See Project E713.
    @questionnaire.name = 'Copy of ' + orig_questionnaire.name
    assign_instructor_id
    @questionnaire.name = 'Copy of '+orig_questionnaire.name
    copy_questionnaire(orig_questionnaire, questions)
  end

  def copy_questionnaire(orig_questionnaire, questions)
    begin
      @questionnaire.created_at = Time.now
      @questionnaire.save!
      questions.each { |question|
        newquestion = question.clone
        newquestion.questionnaire_id = @questionnaire.id
        newquestion.save
        advice = QuestionAdvice.find_by_question_id(question.id)
        if !(advice.nil?)
          newadvice = advice.clone
          newadvice.question_id = newquestion.id
          newadvice.save
        end
      }
      pFolder = TreeFolder.find_by_name(@questionnaire.display_type)
      parent = FolderNode.find_by_node_object_id(pFolder.id)
      check_create_new_node(parent)
      undo_link("Copy of questionnaire #{orig_questionnaire.name} has been created successfully. ")
      redirect_to :back
    rescue
      flash[:error] = 'The questionnaire was not able to be copied. Please check the original course for missing information.'+$!
      redirect_to action: 'list', controller: 'tree_display'
    end
  end

  def check_create_new_node(parent)
    if QuestionnaireNode.where(parent_id: parent.id, node_object_id: @questionnaire.id) == nil
      QuestionnaireNode.create(:parent_id => parent.id, :node_object_id => @questionnaire.id)
    end
  end

  def view
    @questionnaire = Questionnaire.find(params[:id])
  end

  def show
    @questionnaire = Questionnaire.find(params[:id])
  end

  # Define a new questionnaire
  def new
    @questionnaire = Object.const_get(params[:model].split.join).new
  end

  def create
    questionnaire_private = params[:questionnaire][:private] == "true" ? true : false
    display_type = params[:questionnaire][:type].split('Questionnaire')[0]
    @questionnaire = Object.const_get(params[:questionnaire][:type]).new
    @questionnaire.private = questionnaire_private
    @questionnaire.name = params[:questionnaire][:name]
    @questionnaire.instructor_id = session[:user].id
    @questionnaire.min_question_score =  params[:questionnaire][:min_question_score]
    @questionnaire.max_question_score = params[:questionnaire][:max_question_score]
    @questionnaire.type = params[:questionnaire][:type]
    @questionnaire.display_type = display_type
    @questionnaire.instruction_loc = Questionnaire::DEFAULT_QUESTIONNAIRE_URL
    begin
      @questionnaire.save
      #Create node
      tree_folder = TreeFolder.find_by_name(@questionnaire.display_type)
      parent = FolderNode.find_by_node_object_id(tree_folder.id)
      QuestionnaireNode.create(parent_id: parent.id, node_object_id: @questionnaire.id, type: 'QuestionnaireNode')
      flash[:success] = 'You have created a questionnaire successfully!'
    rescue
      flash[:error] = $!
    end
    redirect_to controller: 'tree_display', action: 'list'
  end

  def create_questionnaire
    @questionnaire = Object.const_get(params[:questionnaire][:type]).new(questionnaire_params)
    # TODO: check for Quiz Questionnaire?
    if @questionnaire.type == "QuizQuestionnaire" #checking if it is a quiz questionnaire
      participant_id = params[:pid] #creating a local variable to send as parameter to submitted content if it is a quiz questionnaire
      @questionnaire.min_question_score = 0
      @questionnaire.max_question_score = 1
      @assignment = Assignment.find(params[:aid])
      author_team = AssignmentTeam.team(Participant.find(participant_id))
      @questionnaire.instructor_id = author_team.id    #for a team assignment, set the instructor id to the team_id
      @successful_create = true
      save
      save_choices @questionnaire.id
      if @successful_create
        flash[:note] = "Quiz was successfully created"
      end
      redirect_to controller: 'submitted_content', action: 'edit', id: participant_id
    else #if it is not a quiz questionnaire
      if (session[:user]).role.name == "Teaching Assistant"
        @questionnaire.instructor_id = Ta.get_my_instructor((session[:user]).id)
      end
      save
      redirect_to controller: 'tree_display', action: 'list'
    end
  end

  # Edit a questionnaire
  def edit
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to Questionnaire if @questionnaire == nil
  end

  def update
    @questionnaire = Questionnaire.find(params[:id])
    begin
      @questionnaire.update_attributes(questionnaire_params)
      flash[:success] = 'Questionnaire has been updated successfully!'
    rescue
      flash[:error] = $!
    end
    redirect_to edit_questionnaire_path(@questionnaire.id.to_s.to_sym)
  end

  # Remove a given questionnaire
  def delete
    @questionnaire = Questionnaire.find(params[:id])
    if @questionnaire
      begin
        name = @questionnaire.name
        @questionnaire.assignments.each{
            | assignment |
          raise "The assignment #{assignment.name} uses this questionnaire. Do you want to <A href='../assignment/delete/#{assignment.id}'>delete</A> the assignment?"
        }
        @questionnaire.destroy
        undo_link("Questionnaire \"#{name}\" has been deleted successfully. ")
      rescue
        flash[:error] = $!
      end
    end
    redirect_to action: 'list', controller: 'tree_display'
  end

  def edit_advice  ##Code used to be in this class, was removed.  I have not checked the other class.
    redirect_to controller: 'advice', action: 'edit_advice'
  end

  def save_advice
    begin
      for advice_key in params[:advice].keys
        QuestionAdvice.update(advice_key, params[:advice][advice_key])
      end
      flash[:notice] = "The questionnaire's question advice was successfully saved"
      #redirect_to :action => 'list'
      redirect_to controller: 'advice', action: 'save_advice'
    rescue
      flash[:error] = $!
    end
  end

  # Toggle the access permission for this assignment from public to private, or vice versa
  def toggle_access
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.private = !@questionnaire.private
    @questionnaire.save
    @access = @questionnaire.private == true ? "private" : "public"
    undo_link("Questionnaire \"#{@questionnaire.name}\" has been made #{@access} successfully. ")
    redirect_to controller: 'tree_display', action: 'list'
  end

  #Zhewei: This method is used to add new questions when editing questionnaire.
  def add_new_questions
    questionnaire_id = params[:id] if params[:id] != nil
    (1..params[:question][:total_num].to_i).each do |i|
      question = Object.const_get(params[:question][:type]).create(txt: 'Edit question content here', questionnaire_id: questionnaire_id, seq: i, type: params[:question][:type], break_before: true)
      if question.is_a? ScoredQuestion
        question.weight = 1
        question.max_label = 'Strong agree'
        question.min_label = 'Strong disagree'
      end
      if question.is_a? Criterion
        question.size = '50,3'
      end
      if question.is_a? Dropdown
        question.alternatives = '0|1|2|3|4|5'
      end
      if question.is_a? TextResponse
        question.size = '60,5'
      end
      begin
        question.save
      rescue
        flash[:error] = $!
      end
    end
    redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
  end

  #Zhewei: This method is used to save all questions in current questionnaire.
  def save_all_questions
    questionnaire_id = params[:id] if params[:id] != nil
    if params['save']
      params[:question].each_pair do |k, v|
        @question = Question.find(k)
        #example of 'v' value
        #{"seq"=>"1.0", "txt"=>"WOW", "weight"=>"1", "size"=>"50,3", "max_label"=>"Strong agree", "min_label"=>"Not agree"}
        v.each_pair do |key, value|
          @question.send(key+'=', value) if @question.send(key) != value
        end
        begin
          @question.save
          flash[:success] = 'All questions has been saved successfully!'
        rescue
          flash[:error] = $!
        end
      end
    end
    export if params['export']
    import if params['import']
    if params['view_advice']
      redirect_to controller: 'advice', action: 'edit_advice', id: params[:id]
    else
      redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
    end
  end

  private
  #save questionnaire object after create or edit
  def save
    @questionnaire.save!
    save_questions @questionnaire.id if @questionnaire.id != nil && @questionnaire.id > 0
    # We do not create node for quiz questionnaires
    if @questionnaire.type != "QuizQuestionnaire"
      pFolder = TreeFolder.find_by_name(@questionnaire.display_type)
      parent = FolderNode.find_by_node_object_id(pFolder.id)
      check_create_new_node(parent)
    end
    undo_link("Questionnaire \"#{@questionnaire.name}\" has been updated successfully. ")
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
        q = Question.new()
        q.txt=params[:new_question][question_key]
        q.questionnaire_id = questionnaire_id
        q.type = params[:question_type][question_key][:type]
        q.seq = question_key.to_i
        if @questionnaire.type == "QuizQuestionnaire"
          q.weight = 1 #setting the weight to 1 for quiz questionnaire since the model validates this field
        end
        unless q.txt.strip.empty?
          q.save
        end
      end
    end
  end

  # delete questions from a questionnaire
  # @param [Object] questionnaire_id
  def delete_questions(questionnaire_id)
    # Deletes any questions that, as a result of the edit, are no longer in the questionnaire
    questions = Question.where( "questionnaire_id = " + questionnaire_id.to_s)
    @deleted_questions = []
    for question in questions
      should_delete = true
      if question_params != nil
        for question_key in params[:question].keys
          if question_key.to_s === question.id.to_s
            should_delete = false
          end
        end
      end
      if should_delete
        for advice in question.question_advices
          advice.destroy
        end
        # keep track of the deleted questions
        @deleted_questions.push(question)
        question.destroy
      end
    end
  end

  # Handles questions whose wording changed as a result of the edit
  # @param [Object] questionnaire_id
  def save_questions(questionnaire_id)
    delete_questions questionnaire_id
    save_new_questions questionnaire_id
    if params[:question]
      for question_key in params[:question].keys
        if params[:question][question_key][:txt].strip.empty?
          # question text is empty, delete the question
          Question.delete(question_key)
        else
          # Update existing question.
          question = Question.find(question_key)
          if !question.update_attributes(params[:question][question_key])
            Rails.logger.info(question.errors.messages.inspect)
          end
        end
      end
    end
  end

  #method to save the choices associated with a question in a quiz to the database
  #only for quiz questionnaire
  def save_choices(questionnaire_id)
    if params[:new_question] && params[:new_choices]
      questions = Question.where(questionnaire_id: questionnaire_id)
      questionnum = 1
      for question in questions
        q_type = params[:question_type][questionnum.to_s][:type]
        for choice_key in params[:new_choices][questionnum.to_s][q_type].keys
          if params[:new_choices][questionnum.to_s][q_type][choice_key]["weight"] == 1.to_s
            score = 1
          else
            score = 0
          end
          if(q_type=="MultipleChoiceCheckbox")
            q = save_multiple_choice(choice_key, q_type, question, questionnum)
            q.save
          elsif(q_type=="TrueFalse")
            q = save_truefalse_choice(choice_key, q_type, question, questionnum)
            q.save
          else
            q = save_single_choice(choice_key, q_type, question, questionnum)
            q.save
          end
        end
        questionnum += 1
        question.weight = 1
      end
    end
  end

  def save_truefalse_choice(choice_key, q_type, question, questionnum)
    if (params[:new_choices][questionnum.to_s][q_type][1.to_s][:iscorrect]==choice_key)
      q = QuizQuestionChoice.new(txt: "True", iscorrect: "true", question_id: question.id)
      q.save
      q = QuizQuestionChoice.new(txt: "False", iscorrect: "false", question_id: question.id)
    else
      q = QuizQuestionChoice.new(txt: "True", iscorrect: "false", question_id: question.id)
      q.save
      q = QuizQuestionChoice.new(txt: "False", iscorrect: "true", question_id: question.id)
    end
    q
  end

  def save_single_choice(choice_key, q_type, question, questionnum)
    if (params[:new_choices][questionnum.to_s][q_type][1.to_s][:iscorrect]==choice_key)
      q = QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "true", question_id: question.id)
    else
      q = QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "false", question_id: question.id)
    end
    q
  end

  def save_multiple_choice(choice_key, q_type, question, questionnum)
    if (params[:new_choices][questionnum.to_s][q_type][choice_key][:iscorrect]==1.to_s)
      q = QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "true", question_id: question.id)
    else
      q = QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "false", question_id: question.id)
    end
    q
  end

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :instructor_id, :private, :min_question_score, :max_question_score, :type, :display_type, :instruction_loc)
  end

  def question_params
    params.require(:question).permit(:txt, :weight, :questionnaire_id, :seq, :type, :size, :alternatives, :break_before, :max_label, :min_label)
  end

  # FIXME: These private methods belong in the Questionnaire model

  def export
    @questionnaire = Questionnaire.find(params[:id])
    csv_data = QuestionnaireHelper::create_questionnaire_csv @questionnaire, session[:user].name
    send_data csv_data,
              type: 'text/csv; charset=iso-8859-1; header=present',
              disposition: "attachment; filename=questionnaires.csv"
  end

  def import
    @questionnaire = Questionnaire.find(params[:id])
    file = params['csv']
    @questionnaire.questions << QuestionnaireHelper::get_questions_from_csv(@questionnaire, file)
  end

  # clones the contents of a questionnaire, including the questions and associated advice
  def clone_questionnaire_details(questions, orig_questionnaire)
    assign_instructor_id
    @questionnaire.name = 'Copy of '+orig_questionnaire.name
    begin
      @questionnaire.created_at = Time.now
      @questionnaire.save!
      questions.each do |question|
        newquestion = question.clone
        newquestion.questionnaire_id = @questionnaire.id
        newquestion.save
        advice = QuestionAdvice.find_by_question_id(question.id)
        if advice
          newadvice = advice.clone
          newadvice.question_id = newquestion.id
          newadvice.save
        end
      end
      pFolder = TreeFolder.find_by_name(@questionnaire.display_type)
      parent = FolderNode.find_by_node_object_id(pFolder.id)
      check_create_new_node(parent)
      undo_link("Copy of questionnaire #{orig_questionnaire.name} has been created successfully. ")
      redirect_to controller: 'questionnaire', action: 'view', id: @questionnaire.id
    rescue
      flash[:error] = 'The questionnaire was not able to be copied. Please check the original course for missing information.'+$!
      redirect_to action: 'list', controller: 'tree_display'
    end
  end

  def assign_instructor_id
    if (session[:user]).role.name != "Teaching Assistant"
      @questionnaire.instructor_id = session[:user].id
    else # for TA we need to get his instructor id and by default add it to his course for which he is the TA
      @questionnaire.instructor_id = Ta.get_my_instructor((session[:user]).id)
    end
  end
end
