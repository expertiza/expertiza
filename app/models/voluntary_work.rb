class VoluntaryWork
  attr_accessor :participants, :failure_assignment       , :success
  attr_accessor :extra_reviews, :extra_metareviews, :extra_metareviews_exp, :extra_reviews_exp, :microtask_scores, :microtask_scores_exp
  def initialize (course_id)
    @course_id = course_id
    @success =  calculate_credit_for_voluntary_work
  end


  def calculate_credit_for_voluntary_work
    @participants = Participant.all(:conditions => "parent_id = #{@course_id} AND type = 'CourseParticipant'")
    @assignments = Assignment.all(:conditions => "course_id = #{@course_id}")

    @extra_reviews = Hash.new
    @extra_metareviews = Hash.new
    @extra_reviews_exp = Hash.new
    @extra_metareviews_exp = Hash.new
    @microtask_scores = Hash.new
    @microtask_scores_exp = Hash.new
    @participants.each do |participant|
      review_credit = 0
      metareview_credit = 0
      review_exp_pts = 0
      metareview_exp_pts = 0
      microtask_credit = 0
      microtask_exp_pts = 0
      @assignments.each do |assignment|
        if (Participant.all(:conditions => "parent_id = #{assignment.id} AND user_id = #{participant.user_id}"))
          cnt = 0
          meta_cnt = 0
          review_participant = Participant.all(:conditions => "user_id = #{participant.user_id} AND type = 'AssignmentParticipant' AND parent_id = #{assignment.id}")
          if review_participant.length <= 0
            next
          end

          cnt = ResponseMap.all(:conditions => "reviewed_object_id = #{assignment.id} AND reviewer_id = #{review_participant.first.id}").count

          @meta_maps = MetareviewResponseMap.find_all_by_reviewer_id(review_participant.first.id)
          meta_cnt = @meta_maps.size
          @min_rev = AssignmentReviewWeight.find_by_assignment_id(assignment.id)
          if !@min_rev.nil?
            cnt = cnt - @min_rev.min_num_of_reviews
            meta_cnt = meta_cnt - @min_rev.min_num_of_metareviews
            review_credit += cnt*@min_rev.review_weight
            review_exp_pts += cnt*@min_rev.review_points
            metareview_credit += (meta_cnt*@min_rev.metareview_weight)
            metareview_exp_pts += meta_cnt*@min_rev.metareview_points
          else
            @failure_assignment = assignment.name
            return false
          end

        end

        if assignment.is_microtask?
          if (Participant.all(:conditions => "parent_id = #{assignment.id} AND user_id = #{participant.user_id}"))
            review_participant = Participant.all(:conditions => "user_id = #{participant.user_id} AND type = 'AssignmentParticipant' AND parent_id = #{assignment.id}")
            #review_participant =  AssignmentParticipant.all(:conditions => "user_id = #{participant.user_id} AND type = 'AssignmentParticipant' AND parent_id = #{assignment.id}")
            @microtask_participant = AssignmentParticipant.find(review_participant.first.id)

            if ScoreCache.last(:conditions => "reviewee_id = #{@microtask_participant.id}")
              score = ScoreCache.last(:conditions => "reviewee_id = #{@microtask_participant.id}").score
            else
              score = 0
            end
            topic_id = review_participant.first.topic_id
            if topic_id.nil?
              weight = 0
              exp_pts = 0
            else
              weight = AssignmentWeight.first(:conditions => "topic_id = #{topic_id}").weight
              exp_pts = SignUpTopic.find(topic_id).micropayment
            end
            microtask_credit += score*weight
            microtask_exp_pts += score*exp_pts

          end

        end

      end
      @extra_reviews[participant.id] = review_credit
      @extra_metareviews[participant.id] = metareview_credit
      @extra_reviews_exp[participant.id] = review_exp_pts
      @extra_metareviews_exp[participant.id] = metareview_exp_pts

      @microtask_scores[participant.id] = microtask_credit/100
      @microtask_scores_exp[participant.id] = microtask_exp_pts/100
    end
  end

  def self.get_export_fields(options)
    fields = Array.new
    fields << "Participant Name"
    fields.push("Credit For Reviews")
    fields.push("Credit For Meta Reviews")
    fields.push("Experience points Reviews")
    fields.push("Experience points Meta Reviews")
    fields.push("Credit for Microtasks")
    fields.push("Experience Points for Microtasks")

    return fields
  end

  def self.export(csv, parent_id, options)
    @course_id = parent_id
    @participants = Participant.all(:conditions => "parent_id = #{@course_id} AND type = 'CourseParticipant'")
    @vol_work = VoluntaryWork.new(parent_id)

    @vol_work.calculate_credit_for_voluntary_work
    #fields
    @participants.each do |participant|
      fields = Array.new
      fields << participant.user.name
      fields.push(@vol_work.extra_reviews[participant.id])
      fields.push(@vol_work.extra_metareviews[participant.id])
      fields.push(@vol_work.extra_reviews_exp[participant.id])
      fields.push(@vol_work.extra_metareviews_exp[participant.id])
      fields.push(@vol_work.microtask_scores[participant.id])
      fields.push(@vol_work.microtask_scores_exp[participant.id])
      csv << fields
    end
  end
end