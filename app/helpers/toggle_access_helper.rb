module ToggleAccessHelper
  def toggle_access

    @object = params[:controller].classify.constantize.find(params[:id])
    @object.private = !@object.private

    begin
      @object.save!
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
    @access = @object.private == true ? "private" : "public"

    case params[:controller]
    when 'QuestionnairesController'
      undo_link("The questionnaire \"#{@object.name}\" has been successfully made #{@access}.")
    when 'CourseController'
      undo_link("The course \"#{@object.name}\" has been successfully made #{@access}.")
    end
    redirect_to controller: 'tree_display', action: 'list'
  end
end
