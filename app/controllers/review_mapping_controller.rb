class ReviewMappingController < ApplicationController
  #include GC4R
  autocomplete :user, :name
  #use_google_charts
  require 'gchart'
  helper :dynamic_review_assignment
  helper :submitted_content

  def action_allowed?
    case params[:action]
    when 'add_dynamic_reviewer', 'release_reservation', 'show_available_submissions', 'assign_reviewer_dynamically', 'assign_metareviewer_dynamically', 'add_quiz_response_map', 'assign_quiz_dynamically'
      true
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator'].include? current_role_name
    end
  end

  def auto_complete_for_user_name
    name = params[:user][:name]+"%"
    assignment_id = session[:contributor].parent_id
    @users = User.join(:participants)
      .where( ['participants.type = "AssignmentParticipant" and users.name like ? and participants.parent_id = ?',name,assignment_id])
      .order ('name')

    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end

  def select_reviewer
    assignment = Assignment.find(params[:id])
    @contributor = assignment.get_contributor(params[:contributor_id])
    session[:contributor] = @contributor
  end

  def select_metareviewer
    @mapping = ResponseMap.find(params[:id])
  end

  def add_reviewer
    assignment = Assignment.find(params[:id])
    topic_id = params[:topic_id]
    user_id = User.where(name: params[:user][:name]).first.id
    #If instructor want to assign one student to review his/her own artifact, 
    #it should be counted as “self-review” and we need to make /app/views/submitted_content/_selfreview.html.erb work.
    if TeamsUser.exists?(team_id: params[:contributor_id], user_id: user_id)
      flash[:error] = "You cannot assign this student to review his/her own artifact."
    else
      #Team lazy initialization
      SignUpSheet.signup_team(assignment.id, user_id, topic_id)
      msg = String.new
      begin
        user = User.from_params(params)
        #contributor_id is team_id
        regurl = url_for :action => 'add_user_to_assignment',
          :id => assignment.id,
          :user_id => user.id,
          :contributor_id => params[:contributor_id]

        # Get the assignment's participant corresponding to the user
        reviewer = get_reviewer(user,assignment,regurl)
        #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
        # to treat all assignments as team assignments
        if ReviewResponseMap.where( ['reviewee_id = ? and reviewer_id = ? ',params[:contributor_id],reviewer.id]).first.nil?
          ReviewResponseMap.create(:reviewee_id => params[:contributor_id], :reviewer_id => reviewer.id, :reviewed_object_id => assignment.id)
        else
          raise "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      rescue
          msg = $!
      end
    end
    redirect_to :action => 'list_mappings', :id => assignment.id, :msg => msg
  end

  # Get all the available submissions
  def show_available_submissions
    assignment = Assignment.find(params[:assignment_id])
    reviewer   = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id:  assignment.id).first
    requested_topic_id = params[:topic_id]
    @available_submissions =  Hash.new
    @available_submissions = DynamicReviewAssignmentHelper::review_assignment(assignment.id ,
                                                                              reviewer.id,
                                                                              requested_topic_id ,
                                                                              Assignment::RS_STUDENT_SELECTED)
  end
  def add_quiz_response_map
    if ResponseMap.where(reviewed_object_id: params[:questionnaire_id], reviewer_id:  params[:participant_id]).first
      flash[:error] = "You have already taken that quiz"
    else
      @map = QuizResponseMap.new
      @map.reviewee_id = Questionnaire.find(params[:questionnaire_id]).instructor_id
      @map.reviewer_id = params[:participant_id]
      @map.reviewed_object_id = Questionnaire.find_by_instructor_id(@map.reviewee_id).id
      @map.save
    end
    redirect_to student_quizzes_path(:id => params[:participant_id])
  end

  # Assign self to a submission
  def add_self_reviewer
    assignment = Assignment.find(params[:assignment_id])
    topic_id = params[:topic_id]
    reviewer   = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id:  assignment.id).first
    submission = AssignmentParticipant.find(params[:submission_id],assignment.id)

    if submission.nil?
      flash[:error] = "Could not find a submission to review for the specified topic, please choose another topic to continue."
      redirect_to :controller => 'student_review', :action => 'list', :id => reviewer.id
    else

      begin
        #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
        # to treat all assignments as team assignments
        contributor = get_team_from_submission(submission)
        if ReviewResponseMap.where( ['reviewee_id = ? and reviewer_id = ?', contributor.id, reviewer.id]).first.nil?
          ReviewResponseMap.create(:reviewee_id => contributor.id,
                                       :reviewer_id => reviewer.id,
                                       :reviewed_object_id => assignment.id)
        else
          raise "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
        redirect_to :controller => 'student_review', :action => 'list', :id => reviewer.id
        rescue
          redirect_to :controller => 'student_review', :action => 'list', :id => reviewer.id, :msg => $!
        end

    end
  end

  #  Looks up the team from the submission.
  def get_team_from_submission(submission)
    # Get the list of teams for this assignment.
    teams = AssignmentTeam.where(parent_id:  submission.parent_id)

    teams.each do |team|
      team.teams_users.each do |team_member|
        if team_member.user_id == submission.user_id
          # Found the team, return it!
          return team
        end
      end
    end

    # No team found
    return nil
  end

  #7/12/2015 -zhewei
  #This method is used for assign submissions to students for peer review.
  #This method is different from 'assignment_reviewer_automatically', which is in 'review_mapping_controller' and is used for instructor assigning reviewers in instructor-selected assignment.
  def assign_reviewer_dynamically
    assignment = Assignment.find(params[:assignment_id])
    reviewer   = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id:  assignment.id).first

    if params[:i_dont_care].nil? && params[:topic_id].nil? && assignment.has_topics?
      flash[:error] = "Please go back and select a topic"
    else

      # begin
        if assignment.has_topics?  #assignment with topics
          unless params[:i_dont_care]
            topic = (params[:topic_id].nil?) ? nil : SignUpTopic.find(params[:topic_id])
          else
            topic = assignment.candidate_topics_to_review(reviewer).to_a.shuffle[0] rescue nil
          end
          if topic.nil?
            flash[:error] ="No topics are available to review at this time. Please try later."
          else
            assignment.assign_reviewer_dynamically(reviewer, topic)
          end

        else  #assignment without topic -Yang
          assignment_teams = assignment.candidate_assignment_teams_to_review(reviewer)
          assignment_team = assignment_teams.to_a.shuffle[0] rescue nil
          if assignment_team.nil?
            flash[:error] ="No artifact are available to review at this time. Please try later."
          else
            assignment.assign_reviewer_dynamically_no_topic(reviewer,assignment_team)
          end
        end
      # rescue Exception => e
      #   flash[:error] = (e.nil?) ? $! : e
      # end
    end

    redirect_to :controller => 'student_review', :action => 'list', :id => reviewer.id
  end


  # assigns the quiz dynamically to the participant
  def assign_quiz_dynamically
    begin
      assignment = Assignment.find(params[:assignment_id])
      reviewer   = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id:  assignment.id).first
      if ResponseMap.where(reviewed_object_id: params[:questionnaire_id], reviewer_id:  params[:participant_id]).first
        flash[:error] = "You have already taken that quiz"
      else
        @map = QuizResponseMap.new
        @map.reviewee_id = Questionnaire.find(params[:questionnaire_id]).instructor_id
        @map.reviewer_id = params[:participant_id]
        @map.reviewed_object_id = Questionnaire.find_by_instructor_id(@map.reviewee_id).id
        @map.save
      end

    rescue Exception => e
      flash[:alert] = (e.nil?) ? $! : e
    end
    redirect_to student_quizzes_path(:id => reviewer.id)

  end

  def add_metareviewer
    mapping = ResponseMap.find(params[:id])
    msg = String.new
    begin
      user = User.from_params(params)

      regurl = url_for :action => 'add_user_to_assignment', :id => mapping.map_id, :user_id => user.id
      reviewer = get_reviewer(user,mapping.assignment,regurl)
      if MetareviewResponseMap.where( ['reviewed_object_id = ? and reviewer_id = ?',mapping.map_id,reviewer.id]).first != nil
        raise "The metareviewer \""+reviewer.user.name+"\" is already assigned to this reviewer."
      end
      MetareviewResponseMap.create(:reviewed_object_id => mapping.map_id,
                                   :reviewer_id => reviewer.id,
                                   :reviewee_id => mapping.reviewer.id)
    rescue
      msg = $!
    end
    redirect_to :action => 'list_mappings', :id => mapping.assignment.id, :msg => msg
  end

  def assign_metareviewer_dynamically
      assignment   = Assignment.find(params[:assignment_id])
      metareviewer = AssignmentParticipant.where(user_id: params[:metareviewer_id], parent_id:  assignment.id).first

      assignment.assign_metareviewer_dynamically(metareviewer)


    redirect_to :controller => 'student_review', :action => 'list', :id => metareviewer.id
  end


  def get_user(params)
    if params[:user_id]
      user = User.find(params[:user_id])
    else
      user = User.find_by_name(params[:user][:name])
    end
    if user.nil?
      newuser = url_for :controller => 'users', :action => 'new'
      raise "Please <a href='#{newuser}'>create an account</a> for this user to continue."
    end
    return user
  end

  def get_reviewer(user,assignment,reg_url)
    reviewer = AssignmentParticipant.where(user_id: user.id, parent_id: assignment.id).first
    if reviewer.nil?
      raise "\"#{user.name}\" is not a participant in the assignment. Please <a href='#{reg_url}'>register</a> this user to continue."
    end
    return reviewer
  end


  def add_user_to_assignment
    if params[:contributor_id]
      assignment = Assignment.find(params[:id])
    else
      mapping = ResponseMap.find(params[:id])
      assignment = mapping.assignment
    end

    user = User.find(params[:user_id])
    begin
      assignment.add_participant(user.name)
    rescue
      flash[:error] = $!
    end

    if params[:contributor_id]
      redirect_to :action => 'add_reviewer',     :id => params[:id], :user_id => user.id, :contributor_id => params[:contributor_id]
    else
      redirect_to :action => 'add_metareviewer', :id => params[:id], :user_id => user.id
    end
  end

  def delete_all_reviewers
    assignment = Assignment.find(params[:id])
    team = assignment.get_contributor(params[:contributor_id])
    review_response_maps = team.review_mappings
    num_remain_review_response_maps = review_response_maps.size
    review_response_maps.each do |review_response_map|
      if !Response.exists?(map_id: review_response_map.id)
        ReviewResponseMap.find(review_response_map.id).destroy
        num_remain_review_response_maps -= 1
      end
    end
    if num_remain_review_response_maps > 0
      flash[:error] =  "#{num_remain_review_response_maps} reviewer(s) cannot be deleted bacause they has already started review."
    else
      flash[:success] = "All review mappings for \"#{team.name}\" have been deleted."
    end
    redirect_to :action => 'list_mappings', :id => assignment.id
  end

  def delete_all_metareviewers
    mapping = ResponseMap.find(params[:id])
    mmappings = MetareviewResponseMap.where(reviewed_object_id: mapping.map_id)

    failedCount = ResponseMap.delete_mappings(mmappings, params[:force])
    if failedCount > 0
      url_yes = url_for :action => 'delete_all_metareviewers', :id => mapping.map_id, :force => 1
      url_no  = url_for :action => 'delete_all_metareviewers', :id => mapping.map_id
      flash[:error] = "A delete action failed:<br/>#{failedCount} metareviews exist for these mappings. Delete these mappings anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"
    else
      flash[:note] = "All metareview mappings for contributor \""+mapping.reviewee.name+"\" and reviewer \""+mapping.reviewer.name+"\" have been deleted."
    end
    redirect_to :action => 'list_mappings', :id => mapping.assignment.id
  end

  def delete_mappings(mappings, force=nil)
    failedCount = 0
    mappings.each{
      |mapping|
      assignment_id = mapping.assignment.id
      begin
        mapping.delete(force)
      rescue
        failedCount += 1
      end
    }
    return failedCount
  end

  def delete_participant
    contributor = AssignmentParticipant.find(params[:id])
    name = contributor.name
    assignment_id = contributor.assignment
    begin
      contributor.destroy
      flash[:note] = "\"#{name}\" is no longer a participant in this assignment."
    rescue
      flash[:error] = "\"#{name}\" was not removed. Please ensure that \"#{name}\" is not a reviewer or metareviewer and try again."
      end
    redirect_to :action => 'list_mappings', :id => assignment_id
  end

  def delete_reviewer
    review_response_map = ReviewResponseMap.find(params[:id])
    assignment_id = review_response_map.assignment.id
    if !Response.exists?(map_id: review_response_map.id)
        review_response_map.destroy
        flash[:success] = "The review mapping for \""+review_response_map.reviewee.name+"\" and \""+review_response_map.reviewer.name+"\" have been deleted."
    else
      flash[:error] = "This review has already been done. It cannot been deleted."
    end
    redirect_to :action => 'list_mappings', :id => assignment_id
  end

  def delete_metareviewer
    mapping = MetareviewResponseMap.find(params[:id])
    assignment_id = mapping.assignment.id
    flash[:note] = "The metareview mapping for "+mapping.reviewee.name+" and "+mapping.reviewer.name+" have been deleted."

    begin
      mapping.delete
    rescue
      flash[:error] = "A delete action failed:<br/>" + $! + "<a href='/review_mapping/delete_metareview/"+mapping.map_id.to_s+"'>Delete this mapping anyway>?"
    end

    redirect_to :action => 'list_mappings', :id => assignment_id
  end

  def release_reservation
    mapping = ResponseMap.find(params[:id])
    student_id = mapping.reviewer_id
    mapping.delete
    redirect_to :controller => 'student_review', :action => 'list', :id => student_id
  end

  def delete_review
    mapping = ResponseMap.find(params[:id])
    assignment_id = mapping.assignment.id
    mapping.delete
    #redirect_to :action => 'delete_reviewer', :id => mapping.id
    redirect_to :action => 'list_mappings', :id => assignment_id
  end

  def delete_metareview
    mapping = MetareviewResponseMap.find(params[:id])
    assignment_id = mapping.assignment.id
    #metareview = mapping.response
    #metareview.delete
    mapping.delete
    redirect_to :action => 'list_mappings', :id => assignment_id
  end

  def delete_rofreviewer
    mapping = ResponseMapping.find(params[:id])
    revmapid = mapping.review_mapping.id
    mapping.delete

    flash[:note] = "The metareviewer has been deleted."
    redirect_to :action => 'list_rofreviewers', :id => revmapid
  end

  def list
    all_assignments = Assignment.order('name').where( ["instructor_id = ?",session[:user].id])

    letter = params[:letter]
    if letter == nil
      letter = all_assignments.first.name[0,1].downcase
    end

    @letters = Array.new
    @assignments = Assignment
      .where(["instructor_id = ? and substring(name,1,1) = ?",session[:user].id, letter])
      .order('name')
      .page(params[:page])
      .per_page(10)

    all_assignments.each {
      | assignObj |
      first = assignObj.name[0,1].downcase
      if not @letters.include?(first)
        @letters << first
      end
    }
  end

  def list_mappings
    if params[:msg]
      flash[:error] = params[:msg]
    end
    @assignment = Assignment.find(params[:id])
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @items = AssignmentTeam.where(parent_id: @assignment.id)
    @items.sort{|a,b| a.name <=> b.name}
  end

  def list_sortable
    @assignment = Assignment.find(params[:id])
    @entries = Array.new
    index = 0
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    contributors = AssignmentTeam.where(parent_id: @assignment.id)
    contributors.sort!{|a,b| a.name <=> b.name}
    contributors.each{
      |contrib|
      review_mappings = ResponseMap.where(reviewed_object_id: @assignment.id, reviewee_id: contrib.id)

      if review_mappings.length == 0
        single = Array.new
        single[0] = contrib.name
        single[1] = "&nbsp;"
        single[2] = "&nbsp;"
        @entries[index] = single
        index += 1
      else
        review_mappings.sort!{|a,b| a.reviewer.name <=> b.reviewer.name}
        review_mappings.each{
          |review_map|
          metareview_mappings = MetareviewResponseMap.where(reviewed_object_id: review_map.map_id)
          if metareview_mappings.length == 0
            single = Array.new
            single[0] = contrib.name
            single[1] = review_map.reviewer.name
            single[2] = "&nbsp;"
            @entries[index] = single
            index += 1
          else
            metareview_mappings.sort!{|a,b| a.reviewer.name <=> b.reviewer.name}
            metareview_mappings.each{
              |metareview_map|
              single = Array.new
              single[0] = contrib.name
              single[1] = review_map.reviewer.name
              if metareview_map.review_reviewer == nil
                single[2] = metareview_map.reviewer.name
              else
                single[2] = metareview_map.review_reviewer.name
              end
              @entries[index] = single
              index += 1
            }
          end
        }
      end
    }
    end

  def automatic_review_mapping
    assignment_id = params[:id].to_i
    participants = AssignmentParticipant.where(parent_id: params[:id].to_i).to_a.shuffle!
    teams = AssignmentTeam.where(parent_id: params[:id].to_i).to_a.shuffle!
    max_team_size = Integer(params[:max_team_size]) #Assignment.find(assignment_id).max_team_size
    # Create teams if its an individual assignment.
    if teams.size == 0 and max_team_size == 1
      participants.each do |participant|
        user = participant.user
        unless TeamsUser.team_id(assignment_id, user.id)
          team = AssignmentTeam.create_team_and_node(assignment_id)
          ApplicationController.helpers.create_team_users(participant.user, team.id)
          teams << team
        end
      end
    end
    student_review_num = params[:num_reviews_per_student].to_i
    submission_review_num = params[:num_reviews_per_submission].to_i
    if student_review_num == 0 and submission_review_num == 0
      flash[:error] = "Please choose either the number of reviews per student or the number of reviewers per team (student)."
    elsif student_review_num != 0 and submission_review_num == 0
      #review mapping strategy
      automatic_review_mapping_strategy(assignment_id, participants, teams, student_review_num, submission_review_num)
    elsif student_review_num == 0 and submission_review_num != 0
      #review mapping strategy
      automatic_review_mapping_strategy(assignment_id, participants, teams, student_review_num, submission_review_num)
    else
      flash[:error] = "Please choose either the number of reviews per student or the number of reviewers per team (student), not both."
    end
    redirect_to :action => 'list_mappings', :id => assignment_id
  end

  def automatic_review_mapping_strategy(assignment_id, participants, teams, student_review_num=0, submission_review_num=0)
    participants_hash = {}
    participants.each {|participant| participants_hash[participant.id] = 0 }
    #calculate reviewers for each team
    num_participants = participants.size
    if student_review_num != 0 and submission_review_num == 0
      num_reviews_per_team = (participants.size * student_review_num * 1.0 / teams.size).round
    elsif student_review_num == 0 and submission_review_num != 0
      num_reviews_per_team = submission_review_num
      student_review_num = (teams.size * submission_review_num * 1.0 / participants.size).round
    end
    #Exception detection: If instructor want to assign too many reviews done by each student, there will be an error msg.
    if student_review_num >= teams.size
      flash[:error] = 'You cannot set the number of reviews done by each student to be greater than or equal to total number of teams [or “participants” if it is an individual assignment].'
    end

    iterator = 0
    teams.each do |team|
      temp_array = Array.new
      if !team.equal? teams.last
        #need to even out the # of reviews for teams
        while temp_array.size < num_reviews_per_team
          num_participants_this_team = TeamsUser.where(team_id: team.id).size
          #if all outstanding participants are already in temp_array, just break the loop.
          break if temp_array.size == participants.size - num_participants_this_team
          if iterator == 0
            rand_num = rand(0..num_participants-1)
          else
            min_value = participants_hash.values.min
            #get the temp array including indices of participants, each participant has minimum review number in hash table.
            temp_participant_array = Array.new
            participants.each do |participant|
              temp_participant_array << participants.index(participant) if participants_hash[participant.id] == min_value
            end

            if temp_participant_array.empty? or (temp_participant_array.size == 1 and TeamsUser.exists?(team_id: team.id, user_id: participants[temp_participant_array[0]].user_id))
              #if temp_participant_array is blank 
              #or only one element in temp_participant_array, prohibit one student to review his/her own artifact
              #use original method to get random number
              rand_num = rand(0..num_participants-1)
            else
              #rand_num should be the position of this participant in original array
              rand_num = temp_participant_array[rand(0..temp_participant_array.size-1)]
            end
          end
          if participants_hash[participants[rand_num].id] < student_review_num and !TeamsUser.exists?(team_id: team.id, user_id: participants[rand_num].user_id) and !temp_array.include? participants[rand_num].id
            #prohibit one student to review his/her own artifact and temp_array cannot include duplicate num
            temp_array << participants[rand_num].id
            participants_hash[participants[rand_num].id] += 1
          end 
          #remove students who have already been assigned enough num of reviews out of participants array
          participants.each do |participant|
            if participants_hash[participant.id] == student_review_num
              participants.delete_at(rand_num)
              num_participants -= 1
            end
          end
        end
      else
        #review num for last team can be different from other teams.
        #prohibit one student to review his/her own artifact and temp_array cannot include duplicate num
        participants.each {|participant| temp_array << participant.id if !TeamsUser.exists?(team_id: team.id, user_id: participant.user_id)}
      end
      begin
        temp_array.each do |index|
          ReviewResponseMap.create(:reviewee_id => team.id, :reviewer_id => index,
                                 :reviewed_object_id => assignment_id) if !ReviewResponseMap.exists?(:reviewee_id => team.id, :reviewer_id => index, :reviewed_object_id => assignment_id)
        end
      rescue
        flash[:error] = "Automatic assignment of reviewer failed."
      end
      iterator += 1
    end
  end

  # This is for staggered deadline assignment
  def automatic_review_mapping_staggered
    assignment = Assignment.find(params[:id])
    message = assignment.assign_reviewers_staggered(params[:assignment][:num_reviews], params[:assignment][:num_metareviews])
    flash[:note] = message
    redirect_to :action => 'list_mappings', :id => assignment.id
  end

  def response_report
    # Get the assignment id and set it in an instance variable which will be used in view
    @id = params[:id]
    @assignment = Assignment.find(@id)
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @type =  params.has_key?(:report)? params[:report][:type] : "ReviewResponseMap"

    case @type
    when "ReviewResponseMap"
      if params[:user].nil?
        # This is not a search, so find all reviewers for this assignment
        @reviewers = ResponseMap.select("DISTINCT reviewer_id").where(["reviewed_object_id = ? and type = ?", @id, @type])
      else
        # This is a search, so find reviewers by user's full name
        user = User.select("DISTINCT id").where(["fullname LIKE ?", '%'+params[:user][:fullname]+'%'])
        participants = Participant.select("DISTINCT id").where(["user_id IN (?) and parent_id = ?", user, @assignment.id])
        @reviewers = ResponseMap
          .select("DISTINCT reviewer_id")
          .where(["reviewed_object_id = ? and type = ? and reviewer_id IN (?)", @id, @type, participants] )
      end
      #  @review_scores[reveiwer_id][reviewee_id] = score for assignments not using vary_rubric_by_rounds feature
      # @review_scores[reviewer_id][round][reviewee_id] = score for assignments using vary_rubric_by_rounds feature
      @review_scores = @assignment.compute_reviews_hash
      @avg_and_ranges= @assignment.compute_avg_and_ranges_hash
    when "FeedbackResponseMap"
      #Example query
      #SELECT distinct reviewer_id FROM response_maps where type = 'FeedbackResponseMap' and 
      #reviewed_object_id in (select id from responses where 
      #map_id in (select id from response_maps where reviewed_object_id = 722 and type = 'ReviewResponseMap'))
      @response_map_ids = ResponseMap.select("id").where(["reviewed_object_id = ? and type = ?", @id, 'ReviewResponseMap'])
      @response_ids = Response.select("id").where(["map_id IN (?)", @response_map_ids])
      @reviewers = ResponseMap.select("DISTINCT reviewer_id").where(["reviewed_object_id IN (?) and type = ?", @response_ids, @type])
    end
  end

  # This method should be re-written since the score cache is no longer working.
  def distribution

    @assignment = Assignment.find(params[:id])

    @scores = [0,0,0,0,0,0,0,0,0,0]
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    teams = Team.where(parent_id: params[:id])
    objtype = "ReviewResponseMap"

    teams.each do |team|
      score_cache = ScoreCache.where( ["reviewee_id = ? and object_type = ?",team.id,  objtype]).first
      t_score = 0
      if score_cache!= nil
        t_score = score_cache.score
      end
      if (t_score != 0)
        @scores[(t_score/10).to_i] =  @scores[(t_score/10).to_i] + 1
      end
    end


    #dataset = GoogleChartDataset.new :data => @scores, :color => '9A0000'
    #data = GoogleChartData.new :datasets => [dataset]
    #axis = GoogleChartAxis.new :axis  => [GoogleChartAxis::BOTTOM, GoogleChartAxis::LEFT]
    #@chart1 = GoogleBarChart.new :width => 500, :height => 200
    #@chart1.data = data
    #@chart1.axis = axis
    @chart1 = Gchart.bar(:data => @scores, :size => '500x200')


    ###################### Second Graph ####################

    max_score = 0
    @review_distribution =[0,0,0,0,0,0,0,0,0,0]
    ### For every responsemapping for this assgt, find the reviewer_id and reviewee_id #####
    @reviews_not_done = 0
    response_maps =  ResponseMap.where(["reviewed_object_id = ? and type = ?", @assignment.id, objtype])
    review_report = @assignment.compute_reviews_hash
    for response_map in response_maps
      score_for_this_review = review_report[response_map.reviewer_id][response_map.reviewee_id]
      if(score_for_this_review && score_for_this_review != 0 )
        @review_distribution[(score_for_this_review/10-1).to_i] = @review_distribution[(score_for_this_review/10-1).to_i] + 1
        if (@review_distribution[(score_for_this_review/10-1).to_i] > max_score)
          max_score = @review_distribution[(score_for_this_review/10-1).to_i]
        end
      else
        @reviews_not_done +=1
      end
    end

    #dataset2 = GoogleChartDataset.new :data => @review_distribution, :color => '9A0000'
    #data2 = GoogleChartData.new :datasets => [dataset2]
    #axis2 = GoogleChartAxis.new :axis  => [GoogleChartAxis::BOTTOM, GoogleChartAxis::LEFT]

    #@chart2 = GoogleBarChart.new :width => 500, :height => 200
    #@chart2.data = data2
    #@chart2.axis = axis2
    @chart2 = Gchart.bar(:data =>@review_distribution, :size => '500x200')

    end

end
