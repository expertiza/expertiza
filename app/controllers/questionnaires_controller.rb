class QuestionnairesController < ApplicationController
  include AuthorizationHelper
  before_action [:create_itemnaire, :save], only: [:list]
  include QuestionnaireHelper
  include QuestionHelper


  # Controller for Questionnaire objects
  # A Questionnaire can be of several types (QuestionnaireType)
  # Each Questionnaire contains zero or more items (Question)
  # Generally a itemnaire is associated with an assignment (Assignment)

  before_action :authorize

  # Check role access for edit itemnaire
  def action_allowed?
    case params[:action]
    when 'edit'
      @itemnaire = Questionnaire.find(params[:id])
      current_user_has_admin_privileges? ||
      (current_user_is_a?('Teaching Assistant') && Ta.find(session[:user].id).is_instructor_or_co_ta?(@itemnaire)) ||
      (current_user_is_a?('Instructor') && current_user_id?(@itemnaire.try(:instructor_id))) ||
      (current_user_is_a?('Instructor') && Ta.get_my_instructors(@itemnaire.try(:instructor_id)).include?(session[:user].id))
    else
      current_user_has_student_privileges?
    end
  end

  # Create a clone of the given itemnaire, copying all associated
  # items. The name and creator are updated.
  def copy
    instructor_id = session[:user].instructor_id
    @itemnaire = Questionnaire.copy_itemnaire_details(params, instructor_id)
    p_folder = TreeFolder.find_by(name: @itemnaire.display_type)
    parent = FolderNode.find_by(node_object_id: p_folder.id)
    QuestionnaireNode.find_or_create_by(parent_id: parent.id, node_object_id: @itemnaire.id)
    undo_link("Copy of itemnaire #{@itemnaire.name} has been created successfully.")
    redirect_to controller: 'itemnaires', action: 'view', id: @itemnaire.id
  rescue StandardError
    flash[:error] = 'The itemnaire was not able to be copied. Please check the original course for missing information.' + $ERROR_INFO.to_s
    redirect_to action: 'list', controller: 'tree_display'
  end

  def view
    @itemnaire = Questionnaire.find(params[:id])
  end

  def new
    type = params[:model].split.join
    # Create itemnaire object based on type using itemnaire_factory
    @itemnaire = itemnaire_factory(type) if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:model].split.join
  rescue StandardError
    flash[:error] = $ERROR_INFO
  end

  # Assigns corresponding variables to itemnaire object.
  def set_itemnaire_parameters(private_flag, display)
    @itemnaire.private = private_flag
    @itemnaire.name = params[:itemnaire][:name]
    @itemnaire.instructor_id = session[:user].id
    @itemnaire.min_item_score = params[:itemnaire][:min_item_score]
    @itemnaire.max_item_score = params[:itemnaire][:max_item_score]
    @itemnaire.type = params[:itemnaire][:type]
    @itemnaire.display_type = display
    @itemnaire.instruction_loc = Questionnaire::DEFAULT_QUESTIONNAIRE_URL
    @itemnaire.save
  end

  # Creates tree node
  def create_tree_node
    tree_folder = TreeFolder.where(['name like ?', @itemnaire.display_type]).first
    parent = FolderNode.find_by(node_object_id: tree_folder.id)
    QuestionnaireNode.create(parent_id: parent.id, node_object_id: @itemnaire.id, type: 'QuestionnaireNode')
    flash[:success] = 'You have successfully created a itemnaire!'
  end

  def create
    if params[:itemnaire][:name].blank?
      flash[:error] = 'A rubric or survey must have a title.'
      redirect_to controller: 'itemnaires', action: 'new', model: params[:itemnaire][:type], private: params[:itemnaire][:private]
    else
      itemnaire_private = params[:itemnaire][:private] == 'true'
      display_type = params[:itemnaire][:type].split('Questionnaire')[0]
      begin
        type = params[:itemnaire][:type]
        # Create itemnaire object based on type using itemnaire_factory
        @itemnaire = itemnaire_factory(type) if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:itemnaire][:type]
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
      begin
        # Zhewei: Right now, the display_type in 'itemnaires' table and name in 'tree_folders' table are not consistent.
        # In the future, we need to write migration files to make them have consistency.
        # E1903 : We are not sure of other type of cases, so have added a if statement. If there are only 5 cases, remove the if statement
        if %w[AuthorFeedback CourseSurvey TeammateReview GlobalSurvey AssignmentSurvey BookmarkRating].include?(display_type)
          display_type = display_type.split(/(?=[A-Z])/).join('%')
        end
        # set the parameters for itemnaires object
        set_itemnaire_parameters(itemnaire_private, display_type)
        # Create node - adds this itemnaire to the tree_display list
        create_tree_node
      rescue StandardError => e
        flash[:error] = e.message
      end
      redirect_to controller: 'itemnaires', action: 'edit', id: @itemnaire.id
    end
  end

  # Edit a itemnaire
  def edit
    @itemnaire = Questionnaire.find(params[:id])
    redirect_to Questionnaire if @itemnaire.nil?
    session[:return_to] = request.original_url
  end

  # Updates a itemnaire's attributes and items based on form data and redirects to the edit page,
  # displaying a flash message if the update is successful or not.
  def update
    # If 'Add' or 'Edit/View advice' is clicked, redirect appropriately
    if params[:add_new_items]
      permitted_params = params.permit(:id, new_item: params[:new_item].keys)
      redirect_to action: 'add_new_items', id: permitted_params[:id], item: permitted_params[:new_item]
    elsif params[:view_advice]
      redirect_to controller: 'advice', action: 'edit_advice', id: params[:id]
    else
      @itemnaire = Questionnaire.find(params[:id])
      if @itemnaire.update_attributes(itemnaire_params)
        update_itemnaire_items
        flash[:success] = 'The itemnaire has been successfully updated!'
      else
        flash[:error] = @itemnaire.errors.full_messages.join(', ')
      end
      redirect_to action: 'edit', id: @itemnaire.id.to_s.to_sym
    end
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to action: 'edit', id: @itemnaire.id.to_s.to_sym
  end

  # Remove a given itemnaire
  # checks if any assignment uses the current itemnaire or not
  # checks if there are any answers to the items in the itemnaire
  # for each of the item, it deletes the advice first 
  # and then deletes the item. Only then the itemnaire node
  # is deleted
  def delete
    @itemnaire = Questionnaire.find(params[:id])
    if @itemnaire
      begin
        name = @itemnaire.name
        # if this rubric is used by some assignment, flash error
        unless @itemnaire.assignments.empty?
          raise "The assignment <b>#{@itemnaire.assignments.first.try(:name)}</b> uses this itemnaire. Are sure you want to delete the assignment?"
        end

        items = @itemnaire.items
        # if this rubric had some answers, flash error
        items.each do |item|
          raise 'There are responses based on this rubric, we suggest you do not delete it.' unless item.answers.empty?
        end
        items.each do |item|
          advices = item.item_advices
          advices.each(&:delete)
          item.delete
        end
        itemnaire_node = @itemnaire.itemnaire_node
        itemnaire_node.delete
        @itemnaire.delete
        undo_link("The itemnaire \"#{name}\" has been successfully deleted.")
      rescue StandardError => e
        flash[:error] = e.message
      end
    end
    redirect_to action: 'list', controller: 'tree_display'
  end

  # Toggle the access permission for this assignment from public to private, or vice versa
  def toggle_access
    @itemnaire = Questionnaire.find(params[:id])
    @itemnaire.private = !@itemnaire.private
    @itemnaire.save
    @access = @itemnaire.private == true ? 'private' : 'public'
    undo_link("The itemnaire \"#{@itemnaire.name}\" has been successfully made #{@access}. ")
    redirect_to controller: 'tree_display', action: 'list'
  end

  # Zhewei: This method is used to add new items when editing itemnaire.
  def add_new_items
    itemnaire_id = params[:id]
    # If the itemnaire is being used in the active period of an assignment, delete existing responses before adding new items
    if AnswerHelper.check_and_delete_responses(itemnaire_id)
      flash[:success] = 'You have successfully added a new item. Any existing reviews for the itemnaire have been deleted!'
    else
      flash[:success] = 'You have successfully added a new item.'
    end

    itemnaire = Questionnaire.find(itemnaire_id)
    current_num_of_items = itemnaire.items.size
    max_seq = 0
    Questionnaire.find(itemnaire_id).items.each do |item|
      if !item.seq.nil? && item.seq > max_seq
        max_seq = item.seq
      end
    end
    ((current_num_of_items + 1)..(current_num_of_items + params[:item][:total_num].to_i)).each do
      max_seq += 1
      # Create item object based on type using item_factory
      item = item_factory(params[:item][:type], itemnaire_id, max_seq)
      if item.is_a? ScoredQuestion
        item.weight = params[:item][:weight]
        item.max_label = Question::MAX_LABEL
        item.min_label = Question::MIN_LABEL
      end

      if Question::SIZES.key?(item.class.name)
        item.size = Question::SIZES[item.class.name]
      end
      if Question::ALTERNATIVES.key?(item.class.name)
        item.alternatives = Question::ALTERNATIVES[item.class.name]
      end

      begin
        item.save
      rescue StandardError => e
        flash[:error] = e.message
      end
    end
    redirect_to edit_itemnaire_path(itemnaire_id.to_sym)
  end

  # Zhewei: This method is used to save all items in current itemnaire.
  # this calls update_items on all the items in present itemnaire
  def save_all_items
    itemnaire_id = params[:id]
    begin
      if params[:save]
        update_itemnaire_items
        flash[:success] = 'All items have been successfully saved!'
      end
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end

    if params[:view_advice]
      redirect_to controller: 'advice', action: 'edit_advice', id: params[:id]
    elsif itemnaire_id
      redirect_to edit_itemnaire_path(itemnaire_id.to_sym)
    end
  end

  private

  # save itemnaire object after create or edit
  # this is a basid CRUD function and is called after every create or edit
  def save
    @itemnaire.save!
    redirect_to controller: 'items', action: 'save_items', itemnaire_id: @itemnaire.id, itemnaire_type: @itemnaire.type and return unless @itemnaire.id.nil? || @itemnaire.id <= 0
    undo_link("Questionnaire \"#{@itemnaire.name}\" has been updated successfully. ")
  end

  def itemnaire_params
    params.require(:itemnaire).permit(:name, :instructor_id, :private, :min_item_score,
                                          :max_item_score, :type, :display_type, :instruction_loc)
  end

  def item_params
    params.require(:item).permit(:txt, :weight, :itemnaire_id, :seq, :type, :size,
                                     :alternatives, :break_before, :max_label, :min_label)
  end
end
