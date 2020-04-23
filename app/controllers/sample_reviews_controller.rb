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

        @sample_reviews = SampleReview.all
    end
end
