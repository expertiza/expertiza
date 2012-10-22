# Methods for dynamic review mapping
# called from Assignment class

module DynamicReviewMapping   
  def init()
    teams = self.teams
    @num_teams = teams.size # indicates the num of teams
    students = self.participants
    @num_students = students.size
    populate_review_matrix(students, teams) # the matrix that maps reviewers and teams
    @changed_cells = Array.new 
    @num_max = self.num_reviews* @num_students % @num_teams # the number of teams which can have the max. no. of reviewers
    
    
    @min = self.num_reviews*@num_students/@num_teams # the min # of reviewers a team can have        
    if (@num_max == 0) 
      @max = @min
      @num_max = @num_teams
    else
      @max = @min+1
    end   
    
    # calculates the ones and zeros in each row and column
    populate_row_matrices() 
    populate_column_matrices()    
  end  
  
  def assign_individual_reviewer(round_num)
    stride = 1
    authors = self.participants
    reviewers = self.participants
    if self.participants.size == 0 
      raise "No participants available for assignment"
    end
    
    for i in 0 .. reviewers.size - 1
      current_reviewer_candidate = i
      current_author_candidate = current_reviewer_candidate
      for j in 0 .. (reviewers.size * num_reviews / authors.size) - 1  # This method potentially assigns authors different #s of reviews, if limit is non-integer
        current_author_candidate = (current_author_candidate + stride) % authors.size   
        ParticipantReviewResponseMap.create(:reviewee_id => authors[current_author_candidate].id, :reviewer_id => reviewers[i].id, :reviewed_object_id => self.id)
      end
    end
  end  
   
 def assign_reviewers_for_team(round_num) 
    init()
    for i in 0..@num_students-1 do
      if (row_enough_ones(i) == 1)
        break
      end
      for j in 0..@num_teams-1 do
        failed_mapping_col_wise = false;
        successful_mapping_col_wise = false;
        failed_mapping_row_wise = false;
        successful_mapping_row_wise = false;
        if (@team_review[i][j] == -1)
          @team_review[i][j] = 1
          @rows_ones[i] += 1
          @columns_ones[j] += 1
          if (col_enough_ones(j) == 1) # 
            if (toggle_col(j))
              failed_mapping_col_wise = false              
            end
            if (!failed_mapping_col_wise)
             successful_mapping_col_wise = true 
            end
          else 
            successful_mapping_col_wise = true
          end
          # setting flags for checking failed case
          if(failed_mapping_col_wise)
            successful_mapping_col_wise = false
          end
          if (successful_mapping_col_wise)
              failed_mapping_col_wise = false
          end
          
          if ((row_enough_ones(i) == 1))
            # backup the cells which may be needed to restore later if choice is invalid
            for k in 0..@num_teams-1 do # for each remaining -1 in this row
              if (@team_review[i][k]==-1)
                change_cell(i, k, 0); 
                # if we do this assignment, will it force some students to do 1 too many reviews
                if (col_enough_zeros(k) == 1)
                  if (!toggle_zeros_col(k))
                    failed_mapping_row_wise = true
                  end
                end
              end
            end
          else
            successful_mapping_row_wise = true
          end
          # setting flags
          if(failed_mapping_row_wise)
            successful_mapping_row_wise = false
          end
          if (successful_mapping_row_wise)
              failed_mapping_row_wise = false
          end
          
          if (failed_mapping_col_wise || failed_mapping_row_wise)
            restore()
            populate_row_matrices()
            populate_column_matrices()
          end
        end
      end
    end
    save_mapping(round_num)    
  end    
  
  def save_mapping (round_num)
    i = 0
    j = 0
    self.participants.each{
      | reviewer |
      self.teams.each{
        | reviewee |
        if @team_review[i][j] == 1
          TeamReviewResponseMap.create(:reviewer_id => reviewer.id, :reviewed_object_id => self.id, :reviewee_id => reviewee.id)
        end
        j += 1
      }
      j = 0
      i += 1
    }
  end  
  
  def restore()
    for i in 0..@changed_cells.length-1 do
      @team_review[@changed_cells[i].row][@changed_cells[i].column] = @changed_cells[i].value;
    end
    @changed_cells.clear()
  end  
  
  def populate_review_matrix(students, teams)
    i = 0
    j = 0    
    @team_review = Array.new(students.size).map!{ Array.new(teams.size)}     
    students.each{
      | student |      
      if student.team != nil 
      teams.each{
        | team |        
        if (student.team.id == team.id)
          @team_review[i][j] = 0;   
        else
          @team_review[i][j] = -1;
        end
        j += 1  
      }
      j = 0
      i += 1
      end
    }
  end  
  
  def populate_row_matrices()
    @rows_zeros = Array.new(@num_students, 0) # keeps the track of zeros in each row
    @rows_ones = Array.new(@num_students, 0) # keeps the track of ones in each row        
    
    # populating row wise
    for i in 0..@num_students-1 do
      for j in 0..@num_teams-1 do
        if (@team_review[i][j] == 0) 
          @rows_zeros[i] += 1
        else
          @rows_ones[i] += 1
        end
      end
    end
  end
  
  def populate_column_matrices()
    @columns_zeros = Array.new(@num_teams, 0)# keeps the track of zeros in each column
    @columns_ones = Array.new(@num_teams, 0) # keeps the track of ones in each column
       
    # populating column wise
    for j in 0..@num_teams-1 do
      for i in 0..@num_students-1 do
        if (@team_review[i][j] == 0) 
          @columns_zeros[j] += 1
        else
          @columns_ones[j] += 1
        end
      end
    end 
  end  
   
  
  class CellDescriptor
    attr_accessor :row
    attr_accessor :column
    attr_accessor :value
    def initialize (row, column, value)
      @row, @column, @value = row, column, value
    end
  end    
  
  def change_cell(row, column, value)
    old_value = @team_review[row][column]
    @team_review[row][column] = value;
    if (value == 0)
      @rows_zeros[row]+=1;
      @columns_zeros[column]+=1;
    elsif(value == 1)
      @rows_ones[row]+=1;
      @columns_ones[column]+=1;
    end
    cell = CellDescriptor.new(row, column, old_value)
    @changed_cells << cell   
  end  
  
  def row_enough_zeros(i)
    # this function is used to toggle whether the student i has enough invalid reviewers
    # returns 1 if # of '1's in row i is enough
    # returns -1 if # of '1's in row i is more than enough
    # returns 0 otherwise
    toggle_val = (@num_teams-self.num_reviews)
    if (@rows_zeros[i] == toggle_val)
      return 1
    elsif (@rows_zeros[i] > toggle_val)
      return -1
    else
      return 0
    end
  end  
  
  def row_enough_ones(position)
    # this function is used to toggle whether the student i has enough valid reviewers
    # returns 1 if # of '1's in row i is enough
    # returns -1 if # of '1's in row i is more than enough
    # returns 0 otherwise
    if (@rows_ones[position] == self.num_reviews)
      return 1
    elsif (@rows_ones[position] > self.num_reviews)
      return -1
    else
      return 0
    end
  end
  
  def col_enough_zeros(position)
    # this function is used to toggle whether team j has enough invalid reviewers
    # returns 1 if # of '1's in column j is enough
    # returns -1 if # of '1's in column j is more than enough
    # returns 0 otherwise
    count = 0
    for k in 0..@columns_ones.length-1 do
      if ((position != k) && @columns_ones[k] == (@num_students-@min))
        count +=1
      end
    end
    
    max_allowed_to_have_min_reviewers = @num_teams-@num_max
    max_allowed_to_have_min_reviewers = @num_max if (max_allowed_to_have_min_reviewers == 0)
    if (count == max_allowed_to_have_min_reviewers)
      if (@columns_zeros[position] == (@num_students-@max))
        return 1
      elsif (@columns_zeros[position] > (@num_students-@max))
        return -1
      else 
        return 0  
      end
    elsif (count < max_allowed_to_have_min_reviewers)
      if (@columns_zeros[position] == (@num_students-@min))
        return 1
      elsif (@columns_zeros[position] > (@num_students-@min))
        return -1
      else 
        return 0  
      end
    end
    return -1  
  end 
  
  
  def col_enough_ones(position)
    # this function is used to toggle whether team j has enough valid reviewers
    # returns 1 if # of '1's in column j is enough
    # returns -1 if # of '1's in column j is more than enough
    # returns 0 otherwise
    count = 0
    for k in 0..@columns_ones.length-1 do
      if (@columns_ones[k] == @max)
        count +=1
      end
    end
    
    if (count == @num_max)
      if (@columns_ones[position] == @min)
        return 1
      elsif (@columns_ones[position] > @min)
        return -1
      else
        return 0
      end
    elsif (count < @num_max)
      if (@columns_ones[position] == @max)
        return 1
      elsif (@columns_ones[position] > @max)
        return -1
      else
        return 0
      end
    end
    return -1
  end  
  
  def toggle_zeros_row(position)
    # Precondition: This reviewers has n-r invalid mapping assignments.
    # Set remaining -1s to 1s
    for j in 0..@num_teams-1 do
      if (@team_review[position][j]==-1)
        change_cell(position, j, 1)
        if (col_enough_ones(j) == -1) 
          return false
        elsif (col_enough_ones(j) == 1)
          val = toggle_col(j)
          if (!val)
           return false 
          end
        end
      end
    end
    return true
  end   
  
  def toggle_zeros_col(position)
    # Precondition: This reviewers has n-r invalid mapping assignments.
    # Set remaining -1s to 1s
    for i in 0..@num_students-1 do
      if (@team_review[i][position]==-1)
        change_cell(i, position, 1);
        if (row_enough_ones(position) == -1) 
          return false
        elsif (row_enough_ones(position) == 1)
          val = toggle_row(position)
          if (!val)
           return false 
          end
        end
      end
    end
    return true
  end  
  

  def toggle_row(position)
    # Precondition: This reviewers has enough teams to review. So set remaining "-1"s to "0"s
    # Set remaining -1s to 0s
    for j in 0..@num_teams-1 do
      if (@team_review[position][j]==-1)
        change_cell(position, j, 0)
        if (col_enough_zeros(j) == -1) 
          return false
        elsif (col_enough_zeros(j) == 1)
          val = toggle_zeros_col(j)
          if (!val)
           return false 
          end
        end
      end
    end
    return true
  end

  
  def toggle_col(position)
    # Precondition: This reviewers has enough teams to review. So set remaining "-1"s to "0"s
    # Set remaining -1s to 0s
    for i in 0..@num_students-1 do
      if (@team_review[i][position]==-1)
        change_cell(i, position, 0)
        if (row_enough_zeros(position) == -1) 
          return false
        elsif (row_enough_zeros(position) == 1)
          val = toggle_zeros_row(position)
          if (!val)
           return false 
          end
        end
      end
    end
    return true
  end


 #--------------METHODS BELOW FOR STAGGERED DEADLINE ASSIGNMENT / Assignment with signup sheet-----------------

  #TODO: refactor later to merge with generic code. All the 3 functions have lot of code that is common
  #and all 3 functions work on more or less the same algo 

  def assign_reviewers_automatically(num_reviews, num_review_of_reviews)
    if self.team_assignment?
      review_message = assign_reviewers_team(num_reviews)
    else
      review_message = assign_reviewers_individual(num_reviews)
    end
    metareview_message = assign_metareviewers(num_review_of_reviews, @assignment)

    return review_message.to_s + metareview_message.to_s
  end

  def assign_reviewers_team(num_reviews)

    @assignment = self

    @show_message = false

    number_of_reviews = num_reviews.to_i

    contributors = SignUpTopic.find_by_sql("SELECT creator_id
                                                     FROM sign_up_topics as t,signed_up_users as u
                                                     WHERE t.assignment_id =" + @assignment.id.to_s + " and u.topic_id = t.id")

    users = Array.new
    mappings = Hash.new
    reviews_per_team = 0
    #convert to just an array of contributors(team_ids). Topics which needs review.
    if !contributors.nil?
      contributors.collect! {|contributor| contributor['creator_id'].to_i}
    else
      #TODO: Give up, no work to review ..
    end

    contributors.each { |contributor|
      team_users = TeamsParticipant.find_all_by_team_id(contributor)
      team_users.each { |team_user|
        users.push(team_user['user_id'])
      }
    }

    if users.size != 0
      reviews_per_team = ((users.size.to_f * number_of_reviews.to_f)/contributors.size.to_f).ceil
    else
      #TODO: Give up, no work to reviewers ..
    end

    contributors.each { |contributor|
    #initialize mappings
      mappings[contributor] = Array.new(reviews_per_team)
    }


    #-------------initialize user_review_count----------------
    user_review_count = Hash.new
    users.each {|user|
      user_review_count[user] = number_of_reviews
    }

    #-------------initialize team_reviewers_count-------------
    team_reviewers_count = Hash.new
    contributors.each {|contributor|
      team_reviewers_count[contributor] = reviews_per_team
    }

    temp_users = users.clone

    for i in 1..users.size
      #randomly select a user from the list
      user = temp_users[(rand(temp_users.size)).round]

      #create a list of team_ids this user can review
      users_team_id = Team.find_by_sql("SELECT t.id
                                         FROM teams t, teams_participants u
                                         WHERE t.parent_id = #{@assignment.id.to_s}  and t.id = u.team_id and u.user_id = #{user.to_s}")

      temp_contributors = contributors.clone
      temp_contributors.delete(users_team_id[0].id)

      topic_team_id = Hash.new
      temp_contributors.each {|contributor|
        participant = Participant.find(:all,
                                       :joins => "INNER JOIN teams_participants ON participants.user_id = teams_participants.user_id",
                                       :conditions => "teams_participants.team_id = #{contributor} AND participants.parent_id = #{@assignment.id}")
        topic_team_id[contributor] = participant[0].topic_id
      }


      #Get topic count.
      topic_count = Hash.new
      topic_team_id.each {|record|
        if (topic_count.has_key?(record[1]))
          topic_count[record[1]] = topic_count[record[1]] + 1
        else
          topic_count[record[1]] = 1
        end
      }

      i=0
      #sort topic on count(this will be in ascending)
      temp_topic_count = topic_count.sort {|a, b| a[1]<=>b[1]}

      while user_review_count[user] != 0
        #pick the last one (max count); topic[0] -> topic_id and topic[1] -> count
        topic = temp_topic_count.last

        #if there are no topics this user can review move on to next user
        if topic.nil?
          break
        end

        teams_to_assigned = Array.new
        #check whether it's the user's topic
        users_topic_id = Participant.find_by_parent_id_and_user_id(@assignment.id, user)['topic_id']

        if (topic[0].to_i == users_topic_id.to_i && number_of_reviews < topic[1]) || topic[0].to_i != users_topic_id.to_i
          #go thru team reviewers and find the team which worked on this topic
          topic_team_id.each {|topic_team|
           if topic_team[1].to_i == topic[0].to_i
              #Also before pushing check whether this user is assigned to review this topic earlier
              if mappings[topic_team[0]].index(user).nil?
                teams_to_assigned.push(topic_team[0])
              end
            end
          }
          #here update the mappings datastructure which will be later used to update mappings table
          teams_to_assigned.each {|team|
            if team_reviewers_count[team] != 0 && user_review_count[user] != 0
              mappings[team][(team_reviewers_count[team].to_i) -1] = user
              team_reviewers_count[team] = (team_reviewers_count[team].to_i) - 1
              user_review_count[user] = user_review_count[user] - 1
            else
              if user_review_count[user] == 0
                #We are done with this user
                break
              end
            end
          }
        else
          #don't assign anything.
        end

        #remove that topic from the list
        temp_topic_count.each {|temp_topic|
          if temp_topic[0] == topic[0]
            temp_topic_count.delete(temp_topic)
          end
        }

        #just in case if this loop runs infinitely; can be removed once code stabilizes
        #if (i>user_review_count[user]+10)
        #  break
        #else
        #  i= i + 1
        #end
      end
      temp_users.delete(user)
    end

    mappings.each {|mapping|
    #mapping[0]=team_id and mapping[1]=users(array) assigned for reviewing this team
      for i in 0..mapping[1].size-1
        if mapping[1][i].nil?
          #*try* double the number of users to assign a reviewer to this topic
          for j in (1..users.size*2)
            random_index = rand(users.size-1)

            #check whether this guy is not part of the team
            team = TeamsParticipant.find_by_team_id_and_user_id(mapping[0], users[random_index])
            #if team is nil then this user is not part of the team
            #Also check whether this user has not yet been assigned to review this team
            if team.nil? && mapping[1].index(users[random_index]).nil?
              mapping[1][i] = users[random_index]
              team_reviewers_count[mapping[0]] = (team_reviewers_count[mapping[0]].to_i) - 1
              user_review_count[users[random_index]] = user_review_count[users[random_index]] - 1
              break
            end
          end
        end
      end
    }

    message = "<b>Some students have been assigned more/less than #{number_of_reviews} review(s). </b><br\>"

    #reviewer_assignment_success = true

    user_review_count.each{|user|
      if user[1] > 0
        #reviewer_assignment_success = false
        message_participant = Participant.find_by_parent_id_and_user_id(@assignment.id, user[0])
        users_fullname = message_participant.fullname
        users_name = message_participant.name
        message = message + "<li>" + users_fullname + "("+ users_name.to_s + "): -" + user[1].to_i.abs.to_s + "</li>"
        @show_message = true
      elsif user[1] < 0
        @show_message = true
        message_participant = Participant.find_by_parent_id_and_user_id(@assignment.id, user[0])
        users_fullname = message_participant.fullname
        users_name = message_participant.name
        message = message + "<li>" +users_fullname + "("+ users_name.to_s + "): +" + user[1].to_i.abs.to_s + "</li>"
      else
        #do nothing
      end
    }


    begin
      #Actual mapping
      mappings.each {|mapping|
        team_id = mapping[0]
        reviewers = mapping[1]

        reviewers.each{|reviewer|
          participant = Participant.find_by_parent_id_and_user_id(@assignment.id, reviewer)
          #reviewer, and hence participant could be nil when algo couldn't find someone to review somebody's work
          if !participant.nil?
            reviewer_id = participant.id
            if TeamReviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?', team_id, reviewer_id]).nil?
              TeamReviewResponseMap.create(:reviewee_id => team_id, :reviewer_id => reviewer_id, :reviewed_object_id => @assignment.id)
            else
              #if there is such a review mapping just skip it. Or it can be handled by informing
              #the instructor(TODO:)
            end
          end
        }
      }
      if @show_message == true
        return message
      end
    rescue Exception => exc
      #revert the mapping
      response_mappings = TeamReviewResponseMap.find_all_by_reviewed_object_id(@assignment.id)
      if !response_mappings.nil?
        response_mappings.each {|response_mapping|
          response_mapping.delete
        }
      end
      return "Automatic assignment failed!"
    end


  end

  def assign_reviewers_individual(num_reviews)
    @assignment = self
    @show_message = false
    number_of_reviews = num_reviews.to_i

    contributors = SignUpTopic.find_by_sql("SELECT creator_id
                                             FROM sign_up_topics as t,signed_up_users as u
                                             WHERE t.assignment_id =" + @assignment.id.to_s + " and u.topic_id = t.id")

    users = Array.new
    mappings = Hash.new
    reviews_per_user = 0
    #convert to just an array of contributors(user_ids). Topics which needs review.
    if !contributors.nil?
      contributors.collect! {|contributor| contributor['creator_id'].to_i}
    else
      #TODO: Give up, no work to review ..
    end

    #contributors.each { |contributor|
    #   team_users = TeamsParticipant.find_all_by_team_id(contributor)
    #   team_users.each { |team_user|
    #        users.push(team_user['user_id'])
    #   }
    #}

    users = contributors.clone

    if users.size != 0
      reviews_per_user = ((users.size.to_f * number_of_reviews.to_f)/contributors.size.to_f).ceil
    else
      #TODO: Give up, no work to reviewers ..
    end

    contributors.each { |contributor|
    #initialize mappings
      mappings[contributor] = Array.new(reviews_per_user)
    }


    #-------------initialize user_review_count----------------
    user_review_count = Hash.new
    users.each {|user|
      user_review_count[user] = number_of_reviews
    }

    #-------------initialize team_reviewers_count-------------
    user_reviewers_count = Hash.new
    contributors.each {|contributor|
      user_reviewers_count[contributor] = reviews_per_user
    }

    temp_users = users.clone

    for n in 1..users.size
      #randomly select a user from the list
      user = temp_users[(rand(temp_users.size)).round]
      #create a list of user_ids this user can review
      #users_team_id = Team.find_by_sql("SELECT t.id
      #                                  FROM teams t, teams_participants u
      #                                  WHERE t.parent_id = #{@assignment.id.to_s}  and t.id = u.team_id and u.user_id = #{user.to_s}")

      temp_contributors = contributors.clone
      temp_contributors.delete(user)

      topic_user_id = Hash.new
      temp_contributors.each {|contributor|
        participant = Participant.find_all_by_user_id_and_parent_id(contributor, @assignment.id)
        topic_user_id[contributor] = participant[0].topic_id
      }


      #Get topic count.
      topic_count = Hash.new
      topic_user_id.each {|record|
        if (topic_count.has_key?(record[1]))
          topic_count[record[1]] = topic_count[record[1]] + 1
        else
          topic_count[record[1]] = 1
        end
      }

      i=0
      #sort topic on count(this will be in ascending)
      temp_topic_count = topic_count.sort {|a, b| a[1]<=>b[1]}

      while user_review_count[user] != 0
        #pick the last one (max count); topic[0] -> topic_id and topic[1] -> count
        topic = temp_topic_count.last

        #if there are no topics this user can review move on to next user
        if topic.nil?
          break
        end

        users_to_be_assigned = Array.new
        #check whether it's the user's topic
        users_topic_id = Participant.find_by_parent_id_and_user_id(@assignment.id, user)['topic_id']

        if (topic[0].to_i == users_topic_id.to_i && number_of_reviews < topic[1]) || topic[0].to_i != users_topic_id.to_i


          #go thru reviewers and find the reviewers who worked on this topic
          topic_user_id.each {|topic_user|
            if topic_user[1].to_i == topic[0].to_i
              #Also before pushing check whether this user is assigned to review this topic earlier
              if mappings[topic_user[0]].index(user).nil?
                users_to_be_assigned.push(topic_user[0])
              end
            end
          }
          #here update the mappings datastructure which will be later used to update mappings table
          users_to_be_assigned.each {|reviewer|
            if user_reviewers_count[reviewer] != 0 && user_review_count[user] != 0
              mappings[reviewer][(user_reviewers_count[reviewer].to_i) -1] = user
              user_reviewers_count[reviewer] = (user_reviewers_count[reviewer].to_i) - 1
              user_review_count[user] = user_review_count[user] - 1
            else
              if user_review_count[user] == 0
                #We are done with this user
                break
              end
            end
          }
        else
          #don't assign anything.
        end

        #remove that topic from the list
        temp_topic_count.each {|temp_topic|
          if temp_topic[0] == topic[0]
            temp_topic_count.delete(temp_topic)
          end
        }

        #just in case if this loop runs infinitely; can be removed once code stabilizes
        #if (i>user_review_count[user]+10)
        #  break
        #else
        #  i= i + 1
        #end
      end
      temp_users.delete(user)
    end



    mappings.each {|mapping|
    #mapping[0]=team_id and mapping[1]=users(array) assigned for reviewing this team
      for i in 0..mapping[1].size-1
        if mapping[1][i].nil?
          #*try* double the number of users times to assign a reviewer to this topic
          for j in (1..users.size*2)
            random_index = rand(users.size-1)

            #check whether this randomly picked user is not the contributor
            #Also check whether this user has not yet been assigned to review this team
            if mapping[0].to_i != users[random_index].to_i && mapping[1].index(users[random_index]).nil?
              mapping[1][i] = users[random_index]
              user_reviewers_count[mapping[0]] = (user_reviewers_count[mapping[0]].to_i) - 1
              user_review_count[users[random_index]] = user_review_count[users[random_index]] - 1
              break
            end
          end
        end
      end
    }

    message = "<b>Some students have been assigned more/less than #{number_of_reviews} review(s). </b><br\>"

    #reviewer_assignment_success = true

    user_review_count.each{|user|
      if user[1] > 0
        #reviewer_assignment_success = false
        message_participant = Participant.find_by_parent_id_and_user_id(@assignment.id, user[0])
        users_fullname = message_participant.fullname
        users_name = message_participant.name
        message = message + "<li>" + users_fullname + "("+ users_name.to_s + "): -" + user[1].to_i.abs.to_s + "</li>"
        @show_message = true
      elsif user[1] < 0
        @show_message = true
        message_participant = Participant.find_by_parent_id_and_user_id(@assignment.id, user[0])
        users_fullname = message_participant.fullname
        users_name = message_participant.name
        message = message + "<li>" +users_fullname + "("+ users_name.to_s + "): +" + user[1].to_i.abs.to_s + "</li>"
      else
        #do nothing
      end
    }


    begin
      #Actual mapping
      mappings.each {|mapping|
        reviewee = mapping[0]
        reviewers = mapping[1]

        reviewee_participant = Participant.find_by_parent_id_and_user_id(@assignment.id, reviewee)

        if !reviewee_participant.nil?
          reviewers.each{|reviewer|
            participant = Participant.find_by_parent_id_and_user_id(@assignment.id, reviewer)
            #reviewer, and hence participant could be nil when algo couldn't find someone to review somebody's work
            if !participant.nil?
              reviewer_id = participant.id
              if ParticipantReviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?', reviewee_participant.id, reviewer_id]).nil?
                ParticipantReviewResponseMap.create(:reviewee_id => reviewee_participant.id, :reviewer_id => reviewer_id, :reviewed_object_id => @assignment.id)
              else
                #if there is such a review mapping just skip it. Or it can be handled by informing
                #the instructor(TODO:)
              end
            end
          }
        end
      }

      if @show_message == true
        return message
      end
    rescue Exception => exc
      #revert the mapping
      response_mappings = ResponseMap.find_by_reviewed_object_id_and_type(@assignment.id, "ParticipantReviewResponseMap")
      if !response_mappings.nil?
        response_mappings.each {|response_mapping|
          response_mapping.delete
        }
      end
      return "Automatic assignment failed! Please try again with different number of reviews."
      # include "#{exc.message}" to the above message to find what the error was.."
    end


  end

  def assign_metareviewers(num_review_of_reviews, assignment)

    @show_message = false

    @assignment = assignment
    number_of_reviews = num_review_of_reviews.to_i

    if @assignment.team_assignment?
      contributors = TeamReviewResponseMap.find_all_by_reviewed_object_id(@assignment.id)
    else
      contributors = ParticipantReviewResponseMap.find_all_by_reviewed_object_id(@assignment.id)
    end

    users = Array.new
    mappings = Hash.new
    reviews_per_user = 0

    #convert to just an array of contributors(user_ids). Topics which needs review.
    if !contributors.nil?
      contributors.collect! {|contributor| contributor['id'].to_i}
    else
      #TODO: Give up, no work to review ..
    end

    #contributors.each { |contributor|
    #   team_users = TeamsParticipant.find_all_by_team_id(contributor)
    #   team_users.each { |team_user|
    #        users.push(team_user['user_id'])
    #   }
    #}

    contributors.each {|contributor|
      map = ResponseMap.find(contributor)
      participant = Participant.find(map.reviewer_id)
      users.push(participant.user_id)
    }

    users = users.uniq

    if (users.size * number_of_reviews) < contributors.size
      #TODO: handle with error message
      return "<br/><b>Insufficient metareviewers!</b>"
    end

    if users.size != 0
      reviews_per_user = ((users.size.to_f * number_of_reviews.to_f)/contributors.size.to_f).ceil
    else
      #TODO: Give up, no reviewers ..
    end
    contributors.each { |contributor|
    #initialize mappings
      mappings[contributor] = Array.new(reviews_per_user)
    }


    #-------------initialize user_review_count----------------
    user_review_count = Hash.new
    users.each {|user|
      user_review_count[user] = number_of_reviews
    }

    #-------------initialize team_reviewers_count-------------
    user_reviewers_count = Hash.new
    contributors.each {|contributor|
      user_reviewers_count[contributor] = reviews_per_user
    }

    temp_users = users.clone

    for i in 1..users.size
      #randomly select a user from the list
      user = temp_users[(rand(temp_users.size)).round]
      temp_contributors = contributors.clone
      participant = Participant.find_by_parent_id_and_user_id(@assignment.id, user)
      if !participant.nil?
        contributors.each {|contributor|
          map = ResponseMap.find(contributor)
          if @assignment.team_assignment?
            team_members = TeamsParticipant.find_all_by_team_id(map.reviewee_id)
            if !team_members.nil?
              team_members.each{|team_member|
                if team_member.user_id == user
                  temp_contributors.delete(contributor)
                end
              }
            end
            #also check whether this user was not a reviewer
            if map.reviewer_id == participant.id
              temp_contributors.delete(contributor)
            end
          else
            #check whether this user is not a reviewer nor the reviewee for this review
            if map.reviewee_id == participant.id || map.reviewer_id == participant.id
              temp_contributors.delete(contributor)
            end
          end
        }
      end
      topic_user_id = Hash.new
      temp_contributors.each {|contributor|
        map = ResponseMap.find(contributor)
        #participant = Participant.find_all_by_user_id_and_parent_id(map.reviewee_id, @assignment.id)
        if @assignment.team_assignment?
          team_members = TeamsParticipant.find_all_by_team_id(map.reviewee_id)
          if !team_members.nil?
            participant = Participant.find_by_parent_id_and_user_id(@assignment.id, team_members[0].user_id)
            topic_user_id[contributor] = participant.topic_id
          end
        else
          participant = Participant.find(map.reviewee_id)
          topic_user_id[contributor] = participant.topic_id
        end
      }

      #Get topic count.
      topic_count = Hash.new
      topic_user_id.each {|record|
        if (topic_count.has_key?(record[1]))
          topic_count[record[1]] = topic_count[record[1]] + 1
        else
          topic_count[record[1]] = 1
        end
      }

      i=0
      #sort topic on count(this will be in ascending)
      temp_topic_count = topic_count.sort {|a, b| a[1]<=>b[1]}

      while user_review_count[user] != 0
        #pick the last one (max count); topic[0] -> topic_id and topic[1] -> count
        topic = temp_topic_count.last
        #if there are no topics this user can review move on to next user
        if topic.nil?
          break
        end

        users_to_be_assigned = Array.new
        #check whether it's the user's topic
        users_topic_id = Participant.find_by_parent_id_and_user_id(@assignment.id, user)['topic_id']

        #go thru reviewers and find the reviewers who worked on this topic

        topic_user_id.each {|topic_user|

          if topic_user[1].to_i == topic[0].to_i
            #Also before pushing check whether this user is assigned to review this reviewer earlier
            if mappings[topic_user[0]].index(user).nil?
              users_to_be_assigned.push(topic_user[0])

            end
          end
        }
        #here update the mappings datastructure which will be later used to update mappings table
        users_to_be_assigned.each {|reviewer|
          if user_reviewers_count[reviewer] != 0 && user_review_count[user] != 0
            mappings[reviewer][(user_reviewers_count[reviewer].to_i) -1] = user

            user_reviewers_count[reviewer] = (user_reviewers_count[reviewer].to_i) - 1
            user_review_count[user] = user_review_count[user] - 1
          else
            if user_review_count[user] == 0
              #We are done with this user
              break
            end
          end
        }
        #else
        #don't assign anything.
        #end

        #remove that topic from the list
        temp_topic_count.each {|temp_topic|
          if temp_topic[0] == topic[0]
            temp_topic_count.delete(temp_topic)
          end
        }

        #just in case if this loop runs infinitely; can be removed once code stabilizes
        #if (i>user_review_count[user]+10)
        #  break
        #else
        #  i= i + 1
        #end
      end
      temp_users.delete(user)

    end

    mappings.each {|mapping|
    #mapping[0]=team_id and mapping[1]=users(array) assigned for reviewing this team
      for i in 0..mapping[1].size-1

        if mapping[1][i].nil?
          #*try* double the number of users times to assign a reviewer to this topic
          for j in (1..users.size*4)
            user_can_review = true
            random_index = rand(users.size-1)

            #check whether this randomly picked user is not the contributor
            #Also check whether this user has not yet been assigned to review this team/user
            participant = Participant.find_by_parent_id_and_user_id(@assignment.id, users[random_index])

            map = ResponseMap.find(mapping[0])

            if @assignment.team_assignment?
              team_members = TeamsParticipant.find_all_by_team_id(map.reviewee_id)

              team_members.each {|team_member|
                if team_member.user_id == users[random_index]
                  user_can_review = false
                end
              }
              if participant.id == map.reviewer_id
                user_can_review = false
              end
            else
              if participant.id == map.reviewer_id || participant.id == map.reviewee_id
                user_can_review = false
              end
            end

           if user_can_review == true && mapping[1].index(users[random_index]).nil?

              mapping[1][i] = users[random_index]
              user_reviewers_count[mapping[0]] = (user_reviewers_count[mapping[0]].to_i) - 1
              user_review_count[users[random_index]] = user_review_count[users[random_index]] - 1
              break

            end
          end
        end
      end
    }

    message = "<br/> <b>Some students have been assigned more/less than #{number_of_reviews} metareview(s). </b><br/>"

    #reviewer_assignment_success = true

    user_review_count.each{|user|
      if user[1] > 0
        #reviewer_assignment_success = false
        message_participant = Participant.find_by_parent_id_and_user_id(@assignment.id, user[0])
        users_fullname = message_participant.fullname
        users_name = message_participant.name
        message = message + "<li>" + users_fullname + "("+ users_name.to_s + "): -" + user[1].to_i.abs.to_s + "</li>"
        @show_message = true
      elsif user[1] < 0
        @show_message = true
        message_participant = Participant.find_by_parent_id_and_user_id(@assignment.id, user[0])
        users_fullname = message_participant.fullname
        users_name = message_participant.name
        message = message + "<li>" +users_fullname + "("+ users_name.to_s + "): +" + user[1].to_i.abs.to_s + "</li>"
      else
        #do nothing
      end
    }


    begin
      #Actual mapping
      mappings.each {|mapping|
      #reviewee = mapping[0]
        reviewers = mapping[1]

        map = ResponseMap.find(mapping[0])


        reviewers.each{|reviewer|
          participant = Participant.find_by_parent_id_and_user_id(@assignment.id, reviewer)
          #reviewer, and hence participant could be nil when algo couldn't find someone to review somebody's work
          if !participant.nil?
            reviewer_id = participant.id
            if MetareviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ? and reviewed_object_id = ?', map.reviewer_id, reviewer_id,mapping[0]]).nil?
              MetareviewResponseMap.create(:reviewee_id => map.reviewer_id, :reviewer_id => reviewer_id, :reviewed_object_id => mapping[0])
            else
              #if there is such a review mapping just skip it. Or it can be handled by informing
              #the instructor(TODO:..)
            end
          end
        }

      }
      temp_message = ""
      
      if @show_message == true
        return message + temp_message
      end
    rescue Exception => exc
      #revert the mapping
      response_mappings = MetareviewResponseMap.find_all_by_reviewed_object_id(@assignment.id)
      if !response_mappings.nil?
        response_mappings.each {|response_mapping|
          response_mapping.delete
        }
      end
      return "Automatic meta reviewer assignment failed! Please try again with different number of reviews." + exc.message
      # include "#{exc.message}" to the above message to find what the error was.."
    end


  end
  
end  
