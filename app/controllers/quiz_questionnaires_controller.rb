class QuizQuestionnairesController < QuestionnairesController
  include AuthorizationHelper

  # Quiz itemnaire edit option to be allowed for student
  def action_allowed?
    if params[:action] == 'edit'
      @itemnaire = Questionnaire.find(params[:id])
      current_user_has_admin_privileges? || current_user_is_a?('Student')
    else
      current_user_has_student_privileges?
    end
  end

  # View a quiz itemnaire
  def view
    @itemnaire = Questionnaire.find(params[:id])
    @participant = Participant.find(params[:pid]) # creating an instance variable since it needs to be sent to submitted_content/edit
    render :view
  end

  def new
    valid_request = true # A request is valid if the assignment requires a quiz, the participant has a team, and that team has a topic if the assignment has a topic
    @assignment_id = params[:aid] # creating an instance variable to hold the assignment id
    @participant_id = params[:pid] # creating an instance variable to hold the participant id
    assignment = Assignment.find(@assignment_id)
    if assignment.require_quiz?
      valid_request = team_valid?(@participant_id, assignment) # check for validity of the request
    else # flash error if this assignment does not require quiz
      flash[:error] = 'This assignment is not configured to use quizzes.'
      valid_request = false
    end
    if valid_request && Questionnaire::QUESTIONNAIRE_TYPES.include?(params[:model])
      @itemnaire = QuizQuestionnaire.new
      @itemnaire.private = params[:private]
      render 'itemnaires/new_quiz'
    else
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    end
  end

  # create quiz itemnaire
  def create
    valid = validate_quiz
    if valid.eql?('valid') # The value of valid could either be "valid" or a string indicating why the quiz cannot be created
      @itemnaire = QuizQuestionnaire.new(itemnaire_params)
      participant_id = params[:pid] # Gets the participant id to be used when finding team and editing submitted content
      @itemnaire.min_item_score = params[:itemnaire][:min_item_score] # 0
      @itemnaire.max_item_score = params[:itemnaire][:max_item_score] # 1

      author_team = AssignmentTeam.team(Participant.find(participant_id)) # Gets the participant's team for the assignment

      @itemnaire.instructor_id = author_team.id # for a team assignment, set the instructor id to the team_id

      if @itemnaire.min_item_score < 0 || @itemnaire.max_item_score < 0
        flash[:error] = 'Minimum and/or maximum item score cannot be less than 0.'
        redirect_back fallback_location: root_path
      elsif @itemnaire.max_item_score < @itemnaire.min_item_score
        flash[:error] = 'Maximum item score cannot be less than minimum item score.'
        redirect_back fallback_location: root_path
      else
        @successful_create = true
        save
        save_choices @itemnaire.id
        flash[:note] = 'The quiz was successfully created.' if @successful_create
        redirect_to controller: 'submitted_content', action: 'edit', id: participant_id
      end
    else
      flash[:error] = valid.to_s
      redirect_back fallback_location: root_path
    end
  end

  # edit a quiz itemnaire
  def edit
    @itemnaire = Questionnaire.find(params[:id])
    if @itemnaire.taken_by_anyone?
      flash[:error] = 'Your quiz has been taken by one or more students; you cannot edit it anymore.'
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    else # quiz can be edited only if its not taken by anyone
      render :'itemnaires/edit'
    end
  end

  # save an updated quiz itemnaire to the database
  def update
    @itemnaire = Questionnaire.find(params[:id])
    if @itemnaire.nil?
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
      return
    end
    if params['save'] && params[:item].try(:keys)
      @itemnaire.update_attributes(itemnaire_params)
      params[:item].each_pair do |qid, _|
        @item = Question.find(qid)
        @item.txt = params[:item][qid.to_sym][:txt]
        @item.weight = params[:item_weights][qid.to_sym][:txt]
        @item.save
        @quiz_item_choices = QuizQuestionChoice.where(item_id: qid)
        item_index = 1
        @quiz_item_choices.each do |item_choice| # Updates state of each item choice for selected item
          # Call private methods to handle item types
          update_checkbox(item_choice, item_index) if @item.type == 'MultipleChoiceCheckbox'
          update_radio(item_choice, item_index) if @item.type == 'MultipleChoiceRadio'
          update_truefalse(item_choice) if @item.type == 'TrueFalse'
          item_index += 1
        end
      end
    end
    redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
  end

  # validate quiz name, items, answers
  # Returns "valid" if there are no issues, or a string indicating why the quiz is invalid
  def validate_quiz
    num_items = Assignment.find(params[:aid]).num_quiz_items
    valid = 'valid'
    if params[:itemnaire][:name] == '' # itemnaire name is not specified
      valid = 'Please specify quiz name (please do not use your name or id).'
    end
    (1..num_items).each do |i|
      break unless valid == 'valid'

      valid = validate_item(i)
    end
    valid
  end

  private

  def team_valid?(participant_id, assignment)
    team = AssignmentParticipant.find(participant_id).team
    if team.nil? # flash error if this current participant does not have a team
      flash[:error] = 'You should create or join a team first.'
      false
    elsif assignment.topics? && team.topic.nil? # flash error if this assignment has topic but current team does not have a topic
      flash[:error] = 'Your team should have a topic.'
      false
    else # the current participant is part of a team that has a topic
      true
    end
  end

  # A item is valid if it has a valid type ('TrueFalse', 'MultipleChoiceCheckbox', 'MultipleChoiceRadio') and a correct answer selected
  def validate_item(i)
    if params.key?(:item_type) && params[:item_type].key?(i.to_s) && params[:item_type][i.to_s][:type]
      # The item type is dynamic, so const_get is necessary
      type = params[:item_type][i.to_s][:type]
      @new_item = Object.const_get(type).create(txt: '', type: type, break_before: true)
      @new_item.update_attributes(txt: params[:new_item][i.to_s])
      choice_info = params[:new_choices][i.to_s][type] # choice info for one item of its type
      valid = if choice_info.nil?
                'Please select a correct answer for all items'
              else
                @new_item.isvalid(choice_info)
              end
    else
      # A type isn't selected for a item
      valid = 'Please select a type for each item'
    end
    valid
  end

  # create multiple choice (radio or checkbox) item(s)
  def create_multchoice(item, choice_key, q_answer_choices)
    # this method combines the functionality of create_radio and create_checkbox, so that all mult choice items are create by 1 func
    item_choice = if q_answer_choices[choice_key][:iscorrect] == 1.to_s
                        QuizQuestionChoice.new(txt: q_answer_choices[choice_key][:txt], iscorrect: 'true', item_id: item.id)
                      else
                        QuizQuestionChoice.new(txt: q_answer_choices[choice_key][:txt], iscorrect: 'false', item_id: item.id)
                      end
    item_choice.save
  end

  # create true/false item
  def create_truefalse(item, choice_key, q_answer_choices)
    if q_answer_choices[1.to_s][:iscorrect] == choice_key
      item_choice = QuizQuestionChoice.new(txt: 'True', iscorrect: 'true', item_id: item.id)
      item_choice.save
      item_choice = QuizQuestionChoice.new(txt: 'False', iscorrect: 'false', item_id: item.id)
      item_choice.save
    else
      item_choice = QuizQuestionChoice.new(txt: 'True', iscorrect: 'false', item_id: item.id)
      item_choice.save
      item_choice = QuizQuestionChoice.new(txt: 'False', iscorrect: 'true', item_id: item.id)
      item_choice.save
    end
  end

  # update checkbox item
  def update_checkbox(item_choice, item_index)
    if params[:quiz_item_choices][@item.id.to_s][@item.type][item_index.to_s]
      item_choice.update_attributes(
        iscorrect: params[:quiz_item_choices][@item.id.to_s][@item.type][item_index.to_s][:iscorrect],
        txt: params[:quiz_item_choices][@item.id.to_s][@item.type][item_index.to_s][:txt]
      )
    else
      item_choice.update_attributes(
        iscorrect: '0',
        txt: params[:quiz_item_choices][item_choice.id.to_s][:txt]
      )
    end
  end

  # update radio item
  def update_radio(item_choice, item_index)
    if params[:quiz_item_choices][@item.id.to_s][@item.type][:correctindex] == item_index.to_s
      item_choice.update_attributes(
        iscorrect: '1',
        txt: params[:quiz_item_choices][@item.id.to_s][@item.type][item_index.to_s][:txt]
      )
    else
      item_choice.update_attributes(
        iscorrect: '0',
        txt: params[:quiz_item_choices][@item.id.to_s][@item.type][item_index.to_s][:txt]
      )
    end
  end

  # update true/false item
  def update_truefalse(item_choice)
    if params[:quiz_item_choices][@item.id.to_s][@item.type][1.to_s][:iscorrect] == 'True' # the statement is correct
      item_choice.txt == 'True' ? item_choice.update_attributes(iscorrect: '1') : item_choice.update_attributes(iscorrect: '0')
      # the statement is correct so "True" is the right answer
    else # the statement is not correct
      item_choice.txt == 'True' ? item_choice.update_attributes(iscorrect: '0') : item_choice.update_attributes(iscorrect: '1')
      # the statement is not correct so "False" is the right answer
    end
  end

  # save itemnaire
  def save
    @itemnaire.save!
    undo_link("Questionnaire \"#{@itemnaire.name}\" has been updated successfully. ")
  end

  # save items
  def save_items(itemnaire_id)
    redirect_to controller: 'items', action: 'delete_items', itemnaire_id: @itemnaire.id and return
    redirect_to controller: 'item', action: 'save_new_items', itemnaire_id: @itemnaire.id, itemnaire_type: @itemnaire.type
    if params[:item]
      params[:item].each_key do |item_key|
        if params[:item][item_key][:txt].strip.empty?
          # item text is empty, delete the item
          Question.delete(item_key)
        else
          # Update existing item.
          item = Question.find(item_key)
          Rails.logger.info(item.errors.messages.inspect) unless item.update_attributes(params[:item][item_key])
        end
      end
    end
  end

  # Saves either True/False or Multiple Choice items to a quiz itemnaire
  # Only scorable items can be added to a quiz, but future projects could consider relaxing this constraint
  def save_choices(itemnaire_id)
    return unless params[:new_item] || params[:new_choices]

    items = Question.where(itemnaire_id: itemnaire_id)
    item_num = 1

    items.each do |item|
      q_type = params[:item_type][item_num.to_s][:type]
      q_answer_choices = params[:new_choices][item_num.to_s][q_type]
      q_answer_choices.each_pair do |choice_key, _| # _ is dummy variable
        item_factory(q_type, item, choice_key, q_answer_choices) # allow factory method to create appropriate item
      end
      item_num += 1
      item.weight = 1
    end
  end

  # factory method to create the appropriate item based on the item type (true/false or multiple choice)
  def item_factory(q_type, item, choice_key, q_answer_choices)
    if q_type == 'TrueFalse'
      create_truefalse(item, choice_key, q_answer_choices)
    else # create MultipleChoice of either type, rather than creating them separately based on q_type
      create_multchoice(item, choice_key, q_answer_choices)
    end
  end

  def itemnaire_params
    params.require(:itemnaire).permit(:name, :instructor_id, :private, :min_item_score,
                                          :max_item_score, :type, :display_type, :instruction_loc)
  end
end
