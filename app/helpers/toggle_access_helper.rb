module ToggleAccessHelper
  def toggle_access
    if !Assignment.find_by(id: params[:id]).nil?
      assignment = Assignment.find(params[:id])
      assignment.private = !assignment.private
      assignment.save
    elsif Questionnaire.find(params[:id])
      @questionnaire = Questionnaire.find(params[:id])
      @questionnaire.private = !@questionnaire.private
      @questionnaire.save
      @access = @questionnaire.private == true ? "private" : "public"
      undo_link("the questionnaire \"#{@questionnaire.name}\" has been successfully made #{@access}.")
    elsif !Course.find_by(id: params[:id]).nil?
      @course = Course.find(params[:id])
      @course.private = !@course.private
      begin
        @course.save!
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
      @access = @course.private == true ? "private" : "public"
      undo_link("The course \"#{@course.name}\" has been successfully made #{@access}.")
    end

    redirect_to controller: 'tree_display', action: 'list'
  end
end
