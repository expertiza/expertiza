class LeaderboardController < ApplicationController
  before_filter :authorize

  def action_allowed?
    true
  end

  # Allows to view leaderBoard - sorted on max number of badges received by a course participant
  # E1626
  def index
    if current_user
      @instructor_query = LeaderboardHelper.userIsInstructor?(current_user.id)

      if @instructor_query
        @course_list = LeaderboardHelper.instructorCourses(current_user.id)
      else
        @course_list = LeaderboardHelper.studentInWhichCourses(current_user.id)
      end
      @course_info = Leaderboard.getCourseInfo(@course_list)

      @csHash= Leaderboard.getParticipantEntriesInCourses @course_list, current_user.id

      if !@instructor_query
        @user = current_user
        @courseAccomp = Leaderboard.extractPersonalAchievements(@csHash, @course_list, current_user.id)
      end

      @csHash = Leaderboard.sortHash(@csHash)
      # Setup leaderboard for easier consumption by view
      @leaderboards = Array.new

      @csHash.each { |qType, courseHash|
        courseHash.each_pair { |courseId, userGradeArray|
          courseName = LeaderboardHelper.getCourseName(courseId)
          achieveName = LeaderboardHelper.getAchieveName(qType)

          leaderboardHash = Hash.new
          leaderboardHash = {:achievement => achieveName,
                             :courseName => courseName,
                             :sortedGrades => userGradeArray}

          @leaderboards << leaderboardHash
        }
      }

      @leaderboards.sort! { |x, y| x[:courseName] <=> y[:courseName] }

      # Setup personal achievement leaderboards for easier consumption by view
      @achievementLeaderBoards = Array.new
      if !@instructor_query
        @courseAccomp.each_pair { |course, accompHashArray|
          courseAccompListHash = Hash.new
          courseAccompListHash[:courseName] = LeaderboardHelper.getCourseName(course)
          courseAccompListHash[:accompList] = Array.new
          accompHashArray.each { |accompHash|
            courseAccompListHash[:accompList] << accompHash
          }
          @achievementLeaderBoards << courseAccompListHash
        }
      end

    end
  end

  def view_leaderboard

  end

end
