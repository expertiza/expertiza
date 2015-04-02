class LeaderboardController < ApplicationController

  before_filter :authorize

  def action_allowed?
    true
  end


  # Our logic for the overall leaderboard. This method provides the data for
  # the Top 3 leaderboards and the Personal Achievement leaderboards.
  def index
    if current_user
      @instructorQuery = LeaderboardHelper.userIsInstructor?(current_user.id)

      if @instructorQuery
        @courseList = LeaderboardHelper.instructorCourses(current_user.id)
      else
        @courseList = LeaderboardHelper.studentInWhichCourses(current_user.id)
      end

      @csHash= Leaderboard.getParticipantEntriesInCourses @courseList, current_user.id

      if !@instructorQuery
        @user = current_user
        @courseAccomp = Leaderboard.extractPersonalAchievements(@csHash, @courseList, current_user.id)
      end

      @csHash = Leaderboard.sortHash(@csHash)
      # Setup leaderboard for easier consumption by view
      @leaderboards = Array.new

      @csHash.each { |qType, courseHash|
        courseHash.each_pair{|courseId, userGradeArray|
          courseName = LeaderboardHelper.getCourseName(courseId)
          achieveName = LeaderboardHelper.getAchieveName(qType)

          leaderboardHash = Hash.new
          leaderboardHash = {:achievement => achieveName,
                             :courseName => courseName,
                             :sortedGrades => userGradeArray}

          @leaderboards << leaderboardHash
        }
      }

      @leaderboards.sort!{|x,y| x[:courseName] <=> y[:courseName]}

      # Setup personal achievement leaderboards for easier consumption by view
      @achievementLeaderBoards = Array.new
      if !@instructorQuery
        @courseAccomp.each_pair{ |course, accompHashArray|
          courseAccompListHash = Hash.new
          courseAccompListHash[:courseName] = LeaderboardHelper.getCourseName(course)
          courseAccompListHash[:accompList] = Array.new
          accompHashArray.each {|accompHash|
            courseAccompListHash[:accompList] << accompHash
          }
          @achievementLeaderBoards << courseAccompListHash
        }
      end
    end
  end
end
