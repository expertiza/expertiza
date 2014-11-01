class ReviewMappingController < ApplicationController
  autocomplete :user, :name
  #use_google_charts
  require 'gchart'
  helper :dynamic_review_assignment
  helper :submitted_content

  def action_allowed?
    case params[:action]
    when 'add_dynamic_reviewer', 'release_reservation', 'show_available_submissions', 'assign_reviewer_dynamically', 'assign_metareviewer_dynamically'
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
    msg = String.new
    begin

      user = User.from_params(params)

      regurl = url_for :action => 'add_user_to_assignment',
        :id => assignment.id,
        :user_id => user.id,
        :contributor_id => params[:contributor_id]

      # Get the assignment's participant corresponding to the user
      reviewer = get_reviewer(user,assignment,regurl)
      #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
      # to treat all assignments as team assignments
      if TeamReviewResponseMap.where( ['reviewee_id = ? and reviewer_id = ?',params[:id],reviewer.id]).first.nil?
        TeamReviewResponseMap.create(:reviewee_id => params[:contributor_id], :reviewer_id => reviewer.id, :reviewed_object_id => assignment.id)
      else
        raise "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
      end

      rescue
        msg = $!
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
    redirect_to :controller => 'student_quiz', :action => 'list', :id => params[:participant_id]
  end

  # Assign self to a submission
  def add_self_reviewer
    assignment = Assignment.find(params[:assignment_id])
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
        if TeamReviewResponseMap.where( ['reviewee_id = ? and reviewer_id = ?', contributor.id, reviewer.id]).first.nil?
          TeamReviewResponseMap.create(:reviewee_id => contributor.id,
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

  def assign_reviewer_dynamically
    begin
      assignment = Assignment.find(params[:assignment_id])
      reviewer   = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id:  assignment.id).first

      unless params[:i_dont_care]
        topic = (params[:topic_id].nil?) ? nil : SignUpTopic.find(params[:topic_id])
      else
        topic = assignment.candidate_topics_to_review(reviewer).to_a.shuffle[0] rescue nil
      end

      assignment.assign_reviewer_dynamically(reviewer, topic)

    rescue Exception => e
      flash[:alert] = (e.nil?) ? $! : e
    end

    redirect_to :controller => 'student_review', :action => 'list', :id => reviewer.id
  end

  def assign_metareviewer_dynamically
    begin
      assignment   = Assignment.find(params[:assignment_id])
      metareviewer = AssignmentParticipant.where(user_id: params[:metareviewer_id], parent_id:  assignment.id).first

      assignment.assign_metareviewer_dynamically(metareviewer)

    rescue Exception => e
      flash[:alert] = (e.nil?) ? $! : e
    end

    redirect_to :controller => 'student_review', :action => 'list', :id => metareviewer.id
  end

  # assigns the quiz dynamically to the participant
  def assign_quiz_dynamically
    begin
      assignment = Assignment.find(params[:assignment_id])
      reviewer   = AssignmentParticipant.where(user_id: params[:reviewer_id], parent_id:  assignment.id).first
      #topic_id = Participant.find(Questionnaire.find(params[:questionnaire_id]).instructor_id).topic_id
      unless params[:i_dont_care]
        #topic = (topic_id.nil?) ? nil : SignUpTopic.find(topic_id)
        if ResponseMap.where(reviewed_object_id: params[:questionnaire_id], reviewer_id:  params[:participant_id]).first
          flash[:error] = "You have already taken that quiz"
        else
          @map = QuizResponseMap.new
          @map.reviewee_id = Questionnaire.find(params[:questionnaire_id]).instructor_id
          @map.reviewer_id = params[:participant_id]
          @map.reviewed_object_id = Questionnaire.find_by_instructor_id(@map.reviewee_id).id
          @map.save
        end
      else
        topic = assignment.candidate_topics_for_quiz.to_a.shuffle[0] rescue nil
        assignment.assign_quiz_dynamically(reviewer, topic)
      end



    rescue Exception => e
      flash[:alert] = (e.nil?) ? $! : e
    end
    redirect_to :controller => 'student_quiz', :action => 'list', :id => reviewer.id

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
    begin
      assignment   = Assignment.find(params[:assignment_id])
      metareviewer = AssignmentParticipant.where(user_id: params[:metareviewer_id], parent_id:  assignment.id).first

      assignment.assign_metareviewer_dynamically(metareviewer)

    rescue Exception => e
      flash[:alert] = (e.nil?) ? $! : e
    end

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


  def delete_all_reviewers_and_metareviewers
    assignment = Assignment.find(params[:id])

    failedCount = ResponseMap.delete_mappings(assignment.review_mappings,params[:force])
    if failedCount > 0
      url_yes = url_for :action => 'delete_all_reviewers_and_metareviewers', :id => params[:id], :force => 1
      url_no  = url_for :action => 'delete_all_reviewers_and_metareviewers', :id => params[:id]
      flash[:error] = "A delete action failed:<br/>#{failedCount} reviews exist for these mappings. Delete these mappings anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"
    else
      flash[:note] = "All review mappings for this assignment have been deleted."
    end
    redirect_to :action => 'list_mappings', :id => params[:id]
  end

  def delete_all_reviewers
    assignment = Assignment.find(params[:id])
    contributor = assignment.get_contributor(params[:contributor_id])
    mappings = contributor.review_mappings

    failedCount = ResponseMap.delete_mappings(mappings, params[:force])
    if failedCount > 0
      url_yes = url_for :action => 'delete_all_reviewers', :id => assignment.id, :contributor_id => contributor.id, :force => 1
      url_no  = url_for :action => 'delete_all_reviewers', :id => assignment.id, :contributor_id => contributor.id
      flash[:error] = "A delete action failed:<br/>#{failedCount} reviews and/or metareviews exist for these mappings. Delete these mappings anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"
    else
      flash[:note] = "All review mappings for \""+contributor.name+"\" have been deleted."
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
    mapping = ResponseMap.find(params[:id])
    assignment_id = mapping.assignment.id
    begin
      mapping.delete
      flash[:note] = "The review mapping for \""+mapping.reviewee.name+"\" and \""+mapping.reviewer.name+"\" have been deleted."
    rescue
      flash[:error] = "A delete action failed:<br/>" + $! + "Delete this mapping anyway?&nbsp;<a href='/review_mapping/delete_review/"+mapping.map_id.to_s+"'>Yes</a>&nbsp;|&nbsp;<a href='/review_mapping/list_mappings/#{assignment_id}'>No</a>"
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
    @items.sort!{|a,b| a.name <=> b.name}
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

  def generate_reviewer_mapping
    assignment = Assignment.find(params[:id])

    if params[:selection]
      mapping_strategy = {}
      params[:selection].each do |a|
        if a[0] =~ /^m_/
          mapping_strategy[a[0]] = a[1]
        end
      end
    else
      mapping_strategy = 1
    end

    if assignment.update_attributes(params[:assignment])
      begin
        assignment.assign_reviewers(mapping_strategy)
      rescue
        flash[:error] = "Reviewer assignment failed. Cause: " + $!
      ensure
        redirect_to :action => 'list_mappings', :id => assignment.id
      end
    else
      @wiki_types = WikiType.all
      redirect_to :action => 'list_mappings', :id => assignment.id
    end
  end

  # This is for staggered deadline assignment
  def automatic_reviewer_mapping
    assignment = Assignment.find(params[:id])
    message = assignment.assign_reviewers_staggered(params[:assignment][:num_reviews], params[:assignment][:num_metareviews])
    flash[:note] = message
    redirect_to :action => 'list_mappings', :id => assignment.id
  end


  def select_mapping
    @assignment = Assignment.find(params[:id])
    @review_strategies = ReviewStrategy.order('name')
    @mapping_strategies = MappingStrategy.order('name')
  end

  def review_report
    # Get the assignment id and set it in an instance variable which will be used in view
    @id = params[:id]
    @assignment = Assignment.find(params[:id])
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    @type = "TeamReviewResponseMap"

    if params[:user].nil?
      # This is not a search, so find all reviewers for this assignment
      @reviewers = ResponseMap.select( "DISTINCT reviewer_id").where( ["reviewed_object_id = ? and type = ? ", @id, @type] )
    else
      # This is a search, so find reviewers by user's full name
      us = User.select( "DISTINCT id").where( ["fullname LIKE ?", '%'+params[:user][:fullname]+'%'])
      participants = Participant.select( "DISTINCT id").where( ["user_id IN (?) and parent_id = ?", us, @assignment.id] )
      @reviewers = ResponseMap
        .select( "DISTINCT reviewer_id")
        .where( ["reviewed_object_id = ? and type = ? and reviewer_id IN (?) ", @id, @type, participants] )
    end

    # Arranged as the hash @review_scores[reveiwer_id][reviewee_id] = score for this particular assignment
    @review_scores = @assignment.compute_reviews_hash
    end

  def distribution

    @assignment = Assignment.find(params[:id])

    @scores = [0,0,0,0,0,0,0,0,0,0]
    #ACS Removed the if condition(and corressponding else) which differentiate assignments as team and individual assignments
    # to treat all assignments as team assignments
    teams = Team.where(parent_id: params[:id])
    objtype = "TeamReviewResponseMap"

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
      if(score_for_this_review != 0)
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
