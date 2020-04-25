class SampleReviewsController < ApplicationController
    def action_allowed?
        ['Instructor',
         'Teaching Assistant',
         'Administrator',
         'Super-Administrator',
         'Student'].include? current_role_name and
        ((%w[list].include? action_name) ? are_needed_authorizations_present?(params[:id], "submitter") : true)
    end

    def index

        @all_assignments = SampleReview.where(:assignment_id => params[:id])
        @responses = []
        @all_assignments.each do |assignment|
            @responses << Response.find(SampleReview.find(assignment).response_id)

        end
        


    end

    def map_to_assignment

      params[:assignments].each do |assignment_id|
        @sample_review = SampleReview.create(:response_id => params[:id],:assignment_id=>assignment_id)

      end
      @response = Response.find(params[:id])
      begin
        @map = @response.map

        # Updating visibility for the response object, by E2022 @khotAyush -->
        visibility = 'published'
        @response.update_attribute("visibility",visibility)


      rescue StandardError
        msg = "Your response was not saved. Cause:189 #{$ERROR_INFO}"
      end

      respond_to do |format|
          flash[:notice] = 'Review Marked as Example'
          format.json { render json: @sample_review.id, status: :created }
      end
    end

    def unmap_from_assignment

      SampleReview.where(:response_id=> params[:id]).delete_all

      @response = Response.find(params[:id])
      begin
        @map = @response.map

        # Updating visibility for the response object, by E2022 @khotAyush -->
        visibility = 'public'
        @response.update_attribute("visibility",visibility)


      rescue StandardError
        msg = "Your response was not saved. Cause:189 #{$ERROR_INFO}"
      end

      respond_to do |format|
        flash[:notice] = 'Review Unmarked as Example'
        format.json { head :no_content }
      end
    end
end
