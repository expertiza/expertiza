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
        if (team_review[i][j] == -1)
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
  
end  