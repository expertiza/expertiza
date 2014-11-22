class SectionsController < ApplicationController
  before_action :set_section, only: [:show, :edit, :update, :destroy]
  before_filter :authorize
  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant','Student'].include? current_role_name
  end
  # GET /sections
  def index
    @sections = Section.all
  end

  def send_to_sec_page
    redirect_to section_path
  end
  # GET /sections/1
  def show
  end

  # GET /sections/new
  def new
    @section = Section.new
  end

  # GET /sections/1/edit
  def edit
  end

  # POST /sections
  def create
    @section = Section.new(section_params)

    if @section.save
      redirect_to @section, notice: 'Section was successfully created.'
    else
      render :new
    end
  end

  def select_section

      response_map=ResponseMap.find(params[:id])
      assignment=Assignment.find(params[:assignment_id])
      questionnaire= Questionnaire.find(assignment.review_questionnaire_id)
      questions=questionnaire.questions
      @sections=[]
      questions.each { |question| @sections<< (Section.find(question.sections_id)).name }
      @sections.uniq!


  end
  # PATCH/PUT /sections/1
  def update
    if @section.update(section_params)
      redirect_to @section, notice: 'Section was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /sections/1
  def destroy
    @section.destroy
    redirect_to sections_url, notice: 'Section was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_section
      @section = Section.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def section_params
      params.require(:section).permit(:name, :desc_text)
    end
end
