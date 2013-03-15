module ToggleAccess
# Toggle the access permission for this assignment from public to private, or vice versa
  def toggle_access
    questionnaire = Questionnaire.find(params[:id])
    questionnaire.private = !questionnaire.private
    questionnaire.save

    redirect_to :controller => 'tree_display', :action => 'list'
  end
end
