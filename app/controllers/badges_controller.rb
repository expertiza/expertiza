# E1626
class BadgesController < ApplicationController

  def action_allowed?
    true
  end

  def new
    course_id = params[:course_id]
    @assignments = Assignment.where("course_id = ?", course_id)
    @list_badges = Array.new

    response = get_badges_created(session[:user].id)
    parsed_response = JSON.parse(response.body)
    user_data = nil

    if response.code == '200' && !parsed_response['data'].nil?
      parsed_response['data'].each do |badge|
        @badge_info = Hash.new
        @badge_info["badge_image_url"] = badge["image_url"]
        @badge_info["badge_title"] = badge["title"]
        @badge_info["badge_id"] = badge["id"]
        @list_badges.push @badge_info
      end
    else
      user_data = parsed_response['meta']
    end

    # response = get_badges_created(expertiza_admin_user_id)
    # parsed_response = JSON.parse(response.body)
    #
    # if response.code == '200' && !parsed_response['data'].nil?
    #   user_data = parsed_response['data']
    #   user_data.each do |badge|
    #     @badge_info["badge_image_url"] = badge["image_url"]
    #     @badge_info["badge_title"] = badge["title"]
    #     @badge_info["badge_id"] = badge["id"]
    #     @list_badges.push @badge_info
    #   end
    # else
    #   user_data = parsed_response['meta']
    # end
  end

  def create
    i = 0
    j = 0
  end

  def show
  end

  def index
  end

  def configuration
  end

  private

  def get_badges_created(user_id)
    uri = URI.parse("https://api.credly.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    token = User.select('credly_accesstoken').where("id = ?", user_id)
    request = Net::HTTP::Get.new("/v1.1/me/badges/created?order_direction=ASC&access_token=" + token[0].credly_accesstoken)
    request["X-Api-Key"] = "f14c0138c043c3159420f297276eab61"
    request["X-Api-Secret"] = "6qmzTxOQZJfF5K1ExH80K+umX9gfU5lmtswycO9TycswGbKEIPwuoXxcIohF4d6go0FeLMRv9uV+MD0jmeQsHBDaTNKa+blumqcd+cfK1y5lqTbLiLZsxdue9vth3Lh9U6Juy1rvy2VGYo8EOqh46PMjOmmOTUIZan9vvaf8Z0I="
    response = http.request(request)
    response
  end

end
