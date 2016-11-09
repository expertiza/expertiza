class LeaderboardController < ApplicationController
  before_action :authorize

  def action_allowed?
    true
  end

  # Our logic for the overall leaderboard. This method provides the data for
  # the Top 3 leaderboards and the Personal Achievement leaderboards.
  def index
    if current_user
      @instructorQuery = LeaderboardHelper.userIsInstructor?(current_user.id)

      @courseList = if @instructorQuery
                      LeaderboardHelper.instructorCourses(current_user.id)
                    else
                      LeaderboardHelper.studentInWhichCourses(current_user.id)
                    end

      @csHash = Leaderboard.getParticipantEntriesInCourses @courseList, current_user.id

      unless @instructorQuery
        @user = current_user
        @courseAccomp = Leaderboard.extractPersonalAchievements(@csHash, @courseList, current_user.id)
      end

      @csHash = Leaderboard.sortHash(@csHash)
      # Setup leaderboard for easier consumption by view
      @leaderboards = []

      @csHash.each do |qType, courseHash|
        courseHash.each_pair do |courseId, userGradeArray|
          courseName = LeaderboardHelper.getCourseName(courseId)
          achieveName = LeaderboardHelper.getAchieveName(qType)

          leaderboardHash = {}
          leaderboardHash = {achievement: achieveName,
                             courseName: courseName,
                             sortedGrades: userGradeArray}

          @leaderboards << leaderboardHash
        end
      end

      @leaderboards.sort! {|x, y| x[:courseName] <=> y[:courseName] }

      # Setup personal achievement leaderboards for easier consumption by view
      @achievementLeaderBoards = []
      unless @instructorQuery
        @courseAccomp.each_pair do |course, accompHashArray|
          courseAccompListHash = {}
          courseAccompListHash[:courseName] = LeaderboardHelper.getCourseName(course)
          courseAccompListHash[:accompList] = []
          accompHashArray.each do |accompHash|
            courseAccompListHash[:accompList] << accompHash
          end
          @achievementLeaderBoards << courseAccompListHash
        end
      end
    end
  end
end
