# E1626
class BadgesController < ApplicationController

  def action_allowed?
    case params[:action]
      when 'personal_badges'
        true
      else
        ['Super-Administrator', 'Administrator', 'Instructor', 'Teaching Assistant',].include? current_role_name
    end
  end

  def new
    course_id = params[:course_id]
    @assignments = Assignment.where('course_id = ?', course_id)
    @assignments_list = nil
    @badge_groups = nil
    response = CredlyHelper.get_badges_created(session[:user].id)
    parsed_response = JSON.parse(response.body)

    @badge_groups = BadgeGroup.where('course_id = ? AND is_course_level_group = ?', course_id, true)
    @list_badges, user_data = CredlyHelper.parse_response(parsed_response, response)

    # response = CredlyHelper.get_badges_created(expertiza_admin_user_id)
    # parsed_response = JSON.parse(response.body)
    # if response.code == '200' && !parsed_response['data'].nil?
    #   user_data = parsed_response['data']
    #   user_data.each do |badge|
    #     if Badge.where('credly_badge_id = ?', badge['id']).blank?
    #       new_badge = Badge.new
    #       new_badge.name = badge['title']
    #       new_badge.credly_badge_id = badge['id']
    #       new_badge.save!
    #     end
    #     badge_info = Hash.new
    #     badge_info['badge_image_url'] = badge['image_url']
    #     badge_info['badge_title'] = badge['title']
    #     badge = Badge.where('credly_badge_id = ?', badge['id']).first
    #     badge_info['badge_id'] = badge.id
    #     list_badges.push badge_info
    #   end
    # else
    #   user_data = parsed_response['meta']
    # end
  end

  def create
    badge_strategy = params['badge']['badge_assignment_strategy']
    badge_threshold = ''
    if params['badge']['badge_assignment_threshold'].empty? || params['badge']['badge_assignment_threshold'].nil?
      badge_threshold = params['badge']['badge_assignment_NumBadges']
    else
      badge_threshold = params['badge']['badge_assignment_threshold']
    end
    id_badge_selected = params['badge_selected']

    assignment_id_from_form = Array.new
    params.each do |key, value|
      if key.include? 'assign'
        assignment_id_from_form.push key.split('_', 2).last
      end
    end

    badge_group = BadgeGroup.new
    badge_group.strategy = badge_strategy
    badge_group.threshold = badge_threshold.to_i
    badge_group.is_course_level_group = true
    badge_group.course_id = params[:course_id].to_i
    badge_group.badge_id = id_badge_selected.to_i
    badge_group.save!

    assignment_id_from_form.each do |assgn_id|
      assignment_group = AssignmentGroup.new
      assignment_group.badge_group_id = badge_group.id
      assignment_group.assignment_id = assgn_id.to_i
      assignment_group.save!
    end

    redirect_to badges_configuration_path(:course_id => params[:course_id])
  end

  def show
  end

  def index
  end

  def edit
    @assignments_list = AssignmentGroup.where('badge_group_id = ?', params['badge_group_id'])
    @badgeGroup = BadgeGroup.find_by_id(params['badge_group_id'])
    @assignments = Assignment.where('course_id = ?', @badgeGroup.course_id)
    @list_badges = Array.new
    response = CredlyHelper.get_badges_created(session[:user].id)
    parsed_response = JSON.parse(response.body)
    @list_badges, user_data = CredlyHelper.parse_response(parsed_response, response)
  end

  def update
    badge_strategy = params['badge']['badge_assignment_strategy']
    badge_threshold = ''
    if params['badge']['badge_assignment_threshold'].empty? || params['badge']['badge_assignment_threshold'].nil?
      badge_threshold = params['badge']['badge_assignment_NumBadges']
    else
      badge_threshold = params['badge']['badge_assignment_threshold']
    end
    id_badge_selected = params['badge_selected']

    assignment_id_from_form = Array.new
    params.each do |key, value|
      if key.include? 'assign'
        assignment_id_from_form.push key.split('_', 2).last
      end
    end

    badge_group = BadgeGroup.find_by_id(params['badge_group_id'])
    badge_group.strategy = badge_strategy
    badge_group.threshold = badge_threshold.to_i
    badge_group.is_course_level_group = true
    badge_group.course_id = badge_group.course_id
    badge_group.badge_id = id_badge_selected.to_i
    badge_group.save!

    assignment_group_existing = AssignmentGroup.where('badge_group_id = ?', params['badge_group_id']).destroy_all
    assignment_id_from_form.each do |assgn_id|
      assignment_group = AssignmentGroup.new
      assignment_group.badge_group_id = badge_group.id
      assignment_group.assignment_id = assgn_id.to_i
      assignment_group.save!
    end

    redirect_to badges_configuration_path(:course_id => badge_group.course_id)
  end

  def configuration
    @badge_groups = BadgeGroup.where('course_id = ? and is_course_level_group = TRUE', params[:course_id])
  end

  def award_badges
    @student_list = Leaderboard.getStudentList(params[:course_id])
    @assignments_list = Leaderboard.getAssignmentsIncourse(params[:course_id], params[:user_id])
    response = CredlyHelper.get_badges_created(params[:user_id])
    parsed_response = JSON.parse(response.body)
    @list_badges = Array.new
    user_data = nil

    @list_badges, user_data = CredlyHelper.parse_response(parsed_response, response)

    # response = CredlyHelper.get_badges_created(expertiza_admin_user_id)
    # parsed_response = JSON.parse(response.body)
    # if response.code == '200' && !parsed_response['data'].nil?
    #   user_data = parsed_response['data']
    #   user_data.each do |badge|
    #     if Badge.where('credly_badge_id = ?', badge['id']).blank?
    #       new_badge = Badge.new
    #       new_badge.name = badge['title']
    #       new_badge.credly_badge_id = badge['id']
    #       new_badge.save!
    #     end
    #     badge_info = Hash.new
    #     badge_info['badge_image_url'] = badge['image_url']
    #     badge_info['badge_title'] = badge['title']
    #     badge = Badge.where('credly_badge_id = ?', badge['id']).first
    #     badge_info['badge_id'] = badge.id
    #     list_badges.push badge_info
    #   end
    # else
    #   user_data = parsed_response['meta']
    # end
  end

  def destroy
    #delete Assignment group and Badge Strategies for this category
    AssignmentGroup.where('badge_group_id = ?', params[:badge_group_id]).destroy_all
    badge_group = BadgeGroup.find_by_id(params[:badge_group_id])
    course_id = badge_group.course_id
    badge_group.delete
    redirect_to badges_configuration_path(:course_id => course_id)
  end

  def personal_badges

  end

  def assign_badge_user
    badge_user = BadgeUser.new
    badge_user.badge_id = params['badge_selected']
    badge_user.user_id = params['student_selected']

    if params['is_assignment_level_badge']
      badge_user.is_course_badge = false
      badge_user.assignment_id = params['assignment_selected']
    else
      badge_user.is_course_badge = true
      badge_user.course_id = params[:course_id]
    end

    badge_user.save!

    student_credly_id = User.where('id = ?', params['student_selected']).first
    CredlyHelper.award_badge_user(session[:user].id, student_credly_id.credly_id, params['badge_selected'])

    redirect_to controller: 'leaderboard', action: index
  end

end
