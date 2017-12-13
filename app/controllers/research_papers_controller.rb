class ResearchPapersController < ApplicationController
  before_action :set_research_paper, only: [:show, :edit, :update, :destroy]

  def action_allowed?
    true
  end

  # GET /research_papers
  def index
    @research_papers = ResearchPaper.where(author_id: session[:user_id])
    if @research_papers.nil?
      @research_papers = ResearchPaper.all
    end
  end

  # GET /research_papers/1
  def show
  end

  def display_paper_commands
    if(params[:from])
      session[:paper_id] = params[:research_paper]
    end
    render 'research_papers/display_paper_commands.erb'
  end

  def display_contributors
    render 'research_papers/display_contributors.erb'
  end

  # GET /research_papers/new
  def new
    @research_paper = ResearchPaper.new
  end

  # GET /research_papers/1/edit
  def edit
  end

  # POST /research_papers
  def create
    @research_paper = ResearchPaper.new(research_paper_params)
    @research_paper.author_id = session[:user_id]
    if @research_paper.save
      @paper_writer_map = PaperWriterMapping.new
      @paper_writer_map.writer_id = session[:user_id]
      @paper_writer_map.paper_id = @research_paper.id
      @paper_writer_map.save
      session[:paper_id] = @research_paper.id
      redirect_to @research_paper, notice: 'Research paper was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /research_papers/1
  def update
    if @research_paper.update(research_paper_params)
      redirect_to @research_paper, notice: 'Research paper was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /research_papers/1
  def destroy
    @research_paper.destroy
    redirect_to research_papers_url, notice: 'Research paper was successfully destroyed.'
  end

  def upload
    render 'research_papers/upload.html.erb'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_research_paper
      @research_paper = ResearchPaper.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def research_paper_params
      params.require(:research_paper).permit(:name, :topic, :date, :conference, :attachment)
    end
end
