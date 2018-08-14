class CourseBadgesController < ApplicationController
  before_action :set_course_badge, only: [:show, :edit, :update, :destroy]

  # GET /course_badges
  def index
    @course_badges = CourseBadge.all
  end

  # GET /course_badges/1
  def show
  end

  # GET /course_badges/new
  def new
    @course_badge = CourseBadge.new
  end

  # GET /course_badges/1/edit
  def edit
  end

  # POST /course_badges
  def create
    @course_badge = CourseBadge.new(course_badge_params)

    if @course_badge.save
      redirect_to @course_badge, notice: 'Course badge was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /course_badges/1
  def update
    if @course_badge.update(course_badge_params)
      redirect_to @course_badge, notice: 'Course badge was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /course_badges/1
  def destroy
    @course_badge.destroy
    redirect_to course_badges_url, notice: 'Course badge was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_badge
      @course_badge = CourseBadge.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def course_badge_params
      params.require(:course_badge).permit(:badge_id, :course_id, :award_mechanism, :manual_award_criteria)
    end
end
