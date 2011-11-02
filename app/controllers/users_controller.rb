class UsersController < ApplicationController
  auto_complete_for :user, :name
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end
  
  def self.participants_in(assignment_id)
    users = Array.new
    participants = AssignmentParticipant.find_by_parent_id(assignment_id)    
    participants.each{
      |participant| 
      users << User.find(participant.user_id)
    }
  end

  def auto_complete_for_user_name
    user = session[:user]
    role = Role.find(user.role_id)   
    @users = User.find(:all, :conditions => ['name LIKE ? and (role_id in (?) or id = ?)', "#{params[:user][:name]}%",role.get_available_roles, user.id])
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end
    
 def list
    @noPages=1
    user = session[:user]
    role = Role.find(user.role_id)


    if(session[:opt].nil? && params[:opt].nil?)
    session[:opt]="name"
    end
    if(!session[:opt].nil? && !params[:opt].nil?)
    session[:opt]=params[:opt]
    end


    if(session[:opt].nil? || session[:opt].to_s=='name')
      session[:letter]=nil
    all_users = User.find(:all, :order => 'name', :conditions => ['role_id in (?) or id = ?', role.get_available_roles, user.id])

    letter = params[:letter]
    session[:letter] = letter
    if letter == nil
      letter = all_users.first.name[0,1].downcase
    end
    logger.info "#{letter}"
    @letters = Array.new


    @users = User.paginate(:page => params[:page], :order => 'name',:per_page => 20, :conditions => ["(role_id in (?) or id = ?) and substring(name,1,1) = ?", role.get_available_roles, user.id, letter])
    @userCount=User.count(:order => 'name',:conditions => ["(role_id in (?) or id = ?) and substring(name,1,1) = ?", role.get_available_roles, user.id, letter])
    @noPages=@userCount/20
    all_users.each {
       | userObj |
       first = userObj.name[0,1].downcase
       if not @letters.include?(first)
          @letters << first
       end
    }
    end

    if(session[:opt].to_s=='fullname')
      session[:letter]=nil
      fullname="fullname"
    all_users = User.find(:all, :order => "#{session[:opt]}", :conditions => ['role_id in (?) or id = ?', role.get_available_roles, user.id])

    letter = params[:letter]
    session[:letter] = letter
    if letter == nil
      letter = all_users.first.fullname[0,1].downcase
    end
    logger.info "#{letter}"
    @letters = Array.new
    @users = User.paginate(:page => params[:page], :order => "#{session[:opt]}", :per_page => 20, :conditions => ["(role_id in (?) or id = ?) and substring(fullname,1,1) = ?", role.get_available_roles, user.id, letter])
    @userCount= User.count(:order => "#{session[:opt]}",:conditions => ["(role_id in (?) or id = ?) and substring(fullname,1,1) = ?", role.get_available_roles, user.id, letter])


     @noPages=@userCount/20
      all_users.each {
       | userObj |
       first = userObj.fullname[0,1].downcase
       if not @letters.include?(first)
          @letters << first
       end
    }
   end

  if(session[:opt].nil? || session[:opt].to_s=='email')
    session[:letter]=nil
    all_users = User.find(:all, :order => 'email', :conditions => ['role_id in (?) or id = ?', role.get_available_roles, user.id])

    letter = params[:letter]
    session[:letter] = letter
    if letter == nil
      letter = all_users.first.email[0,1].downcase
    end
    logger.info "#{letter}"
    @letters = Array.new
    @users = User.paginate(:page => params[:page], :order => 'email', :per_page => 20, :conditions => ["(role_id in (?) or id = ?) and substring(email,1,1) = ?", role.get_available_roles, user.id, letter])
    @userCount=User.count(:order => 'email',:conditions => ["(role_id in (?) or id = ?) and substring(email,1,1) = ?", role.get_available_roles, user.id, letter])
    @noPages=@userCount/20
    all_users.each {
       | userObj |
       first = userObj.email[0,1].downcase
       if not @letters.include?(first)
          @letters << first
       end
    }
    end

    if(session[:opt].nil? || session[:opt].to_s=='role_id')
        session[:letter]=nil
        @allRoles = Role.find(:all,:order => "name")
        @rolesAsc= Array.new
        @allRoles.each do |roleRec|
         @rolesAsc<<roleRec.id
        end
        all_users=Array.new
        @rolesAsc.each do |roleno|
        recs= User.find(:all, :conditions => ['role_id = ?', roleno])
        recs.each do |rec|
          all_users<<rec
        end
        end

        #all_users = User.find(:all, :order => 'role_id', :conditions => ['role_id in (?) or id = ?', role.get_available_roles, user.id])

        if !params[:letter].nil?
          session[:letter] = params[:letter]


        record=Role.find_by_name(params[:letter])
        letter=record.id


        end
        #session[:letter] = letter
        if letter == nil
          letter = all_users[0].role_id
        end
        logger.info "#{letter}"
        @letters = Array.new
        @users = User.paginate(:page => params[:page], :order => 'role_id', :per_page => 20, :conditions => ["(role_id in (?) or id = ?) and substring(role_id,1,1) = ?", role.get_available_roles, user.id, letter])
        @userCount=User.count(:order => 'role_id', :conditions => ['(role_id = ?)', letter])
        @noPages=@userCount/20
        all_users.each {
           | userObj |
           first = userObj.role.name
           if not @letters.include?(first)
              @letters << first
           end
          }
         @letters= @letters.sort
    end



    if(session[:opt].nil? || session[:opt].to_s=='parent_id')
        session[:letter]=nil

        @parentIDs=User.find_by_sql("select DISTINCT(parent_id) from Users")
        @parentNames=Array.new
        @parentIDs.each do |pid|
         @parentNames<<(User.find_by_id(pid.parent_id)).name
        end


        @parentNames=@parentNames.sort

        @spids = Array.new
        @parentNames.each do |n|
         @spids<< (User.find_by_name(n)).id
        end

        all_users= Array.new
        @spids.each do |spid|
        recs= User.find(:all, :conditions => ['id = ?', spid])
        recs.each do |rec|
          all_users<<rec
        end
        end

        #all_users = User.find(:all, :order => 'role_id', :conditions => ['role_id in (?) or id = ?', role.get_available_roles, user.id])

        if !params[:letter].nil?
          session[:letter] = params[:letter]

        record=User.find_by_name(params[:letter])
        letter=record.id

        end
        #session[:letter] = letter
        if letter == nil
          letter = @spids[0]
        end
        logger.info "#{letter}"
        @letters = Array.new
        @users = User.paginate(:page => params[:page], :order => 'parent_id', :per_page => 20, :conditions => ["parent_id = ?",letter])
        @userCount=User.count(:order => 'parent_id',:conditions => ["parent_id = ?",letter])
        @noPages=@userCount/20
        all_users.each {
           | userObj |
           first = User.find(userObj.parent_id).name
           if not @letters.include?(first)
              @letters << first
           end
          }
         @letters= @letters.sort
    end


    if(session[:opt].nil? || session[:opt].to_s=='review')
      if(session[:letter] != 1 || session[:letter]!=0 || session[:letter].nil?)
        session[:letter]=0
      end
    all_users = User.find(:all, :order => 'email_on_review')

      if params[:letter].nil?
        letter=session[:letter]
      end
      if (params[:letter]=="yes" || params[:letter]=="1")

        letter=1
      end
      if (params[:letter]=="no" || params[:letter]=="0")

        letter=0
      end
      #if params[:letter]=="blank"
      #  letter=""
      #end

    session[:letter] = letter

      p session[:letter]

    logger.info "#{letter}"
    @letters = Array.new

    @users = User.paginate(:page => params[:page], :order => 'email_on_review',:per_page => 20, :conditions => ["email_on_review = ?",letter])
    @userCount=User.count(:order => 'email_on_review',:conditions => ["email_on_review = ?",letter])
    @noPages=@userCount/20
    all_users.each {
       | userObj |
       first = User.yesorno(userObj.email_on_review)
       if(first=="")

           first="no"
       end
       if not @letters.include?(first)
          @letters << first

       end
    }

  end


  if(session[:opt].nil? || session[:opt].to_s=='submission')
      if(session[:letter] != 1 || session[:letter]!=0 || session[:letter].nil?)
        session[:letter]=0
      end
    all_users = User.find(:all, :order => 'email_on_submission')

      if params[:letter].nil?
        letter=session[:letter]
      end
      if (params[:letter]=="yes" || params[:letter]=="1")
       letter=1
      end
      if (params[:letter]=="no" || params[:letter]=="0")

        letter=0
      end
      #if params[:letter]=="blank"
      #  letter=""
      #end

    session[:letter] = letter

      p session[:letter]

    logger.info "#{letter}"
    @letters = Array.new

    @users = User.paginate(:page => params[:page], :order => 'email_on_submission',:per_page => 20, :conditions => ["email_on_submission = ?",letter])
    @userCount=User.count(:order => 'email_on_submission',:conditions => ["email_on_submission = ?",letter])
    @noPages=@userCount/20
    all_users.each {
       | userObj |
       first = User.yesorno(userObj.email_on_submission)
       if(first=="")

           first="no"
       end
       if not @letters.include?(first)
          @letters << first


       end
    }

    end



  if(session[:opt].nil? || session[:opt].to_s=='metareview')
      if(session[:letter] != 1 || session[:letter]!=0 || session[:letter].nil?)
        session[:letter]=0
      end
    all_users = User.find(:all, :order => 'email_on_review_of_review')

      if params[:letter].nil?
        letter=session[:letter]
      end
      if (params[:letter]=="yes" || params[:letter]=="1")

        letter=1
      end
      if (params[:letter]=="no" || params[:letter]=="0")

        letter=0
      end
      #if params[:letter]=="blank"
      #  letter=""
      #end

    session[:letter] = letter

      p session[:letter]

    logger.info "#{letter}"
    @letters = Array.new

    @users = User.paginate(:page => params[:page], :order => 'email_on_review_of_review',:per_page => 20, :conditions => ["email_on_review_of_review = ?",letter])
    @userCount=User.count(:order => 'email_on_review_of_review',:conditions => ["email_on_review_of_review = ?",letter])
    @noPages=@userCount/20
    all_users.each {
       | userObj |
       first = User.yesorno(userObj.email_on_review_of_review)
       if(first=="")

           first="no"
       end
       if not @letters.include?(first)
          @letters << first

       end
    }

    end



   if(session[:opt].nil? || session[:opt].to_s=='privacy')
      if(session[:letter] != 1 || session[:letter]!=0 || session[:letter].nil?)
        session[:letter]=0
      end
    all_users = User.find(:all, :order => 'leaderboard_privacy')

      if params[:letter].nil?
        letter=session[:letter]
      end
      if (params[:letter]=="yes" || params[:letter]=="1")

        letter=1
      end
      if (params[:letter]=="no" || params[:letter]=="0")

        letter=0
      end

    session[:letter] = letter

      p session[:letter]

    logger.info "#{letter}"
    @letters = Array.new

    @users = User.paginate(:page => params[:page], :order => 'leaderboard_privacy',:per_page => 20, :conditions => ["leaderboard_privacy = ?",letter])
    @userCount=User.count(:order => 'leaderboard_privacy',:conditions => ["leaderboard_privacy = ?",letter])
    @noPages=@userCount/20
    all_users.each {
       | userObj |
       first = User.yesorno(userObj.leaderboard_privacy)
       if(first=="")

           first="no"
       end
       if not @letters.include?(first)
          @letters << first

       end
    }

    end
  end

  def show_selection
    @user = User.find_by_name(params[:user][:name])
    if @user != nil
       get_role
       if @role.parent_id == nil || @role.parent_id < (session[:user]).role_id || @user.id == (session[:user]).id
          render :action => 'show'
      else
          flash[:note] = 'The specified user is not available for editing.'      
          redirect_to :action => 'list'
      end
    else
        flash[:note] = params[:user][:name]+' does not exist.'
        redirect_to :action => 'list'
    end
  end
  
  def show
    @user = User.find(params[:id])
    get_role
  end
  
  def new
    @user = User.new
    foreign
  end

  def create
    # if the user name already exists, register the user by email address
    check = User.find_by_name(params[:user][:name])
    if check != nil
      params[:user][:name] = params[:user][:email]
    end
    
    @user = User.new(params[:user])
    # record the person who created this new user
    @user.parent_id = (session[:user]).id
    
    if @user.save
      #Instructor and Administrator users need to have a default set for their notifications
      # the creation of an AssignmentQuestionnaires object with only the User ID field populated
      # ensures that these users have a default value of 15% for notifications.
      #TAs and Students do not need a default. TAs inherit the default from the instructor,
      # Students do not have any checks for this information.
      if @user.role.name == "Instructor" or @user.role.name == "Administrator"
        AssignmentQuestionnaires.create(:user_id => @user.id)
      end
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      foreign
      render :action => 'new'
    end
  end


  def edit
    @user = User.find(params[:id])
    get_role
    foreign
  end

  def update
    @user = User.find(params[:id])   

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      foreign
      render :action => 'edit'
    end
  end


  def destroy
    begin
       user = User.find(params[:id])
       AssignmentParticipant.find_all_by_user_id(user.id).each{|participant| participant.delete}
       TeamsUser.find_all_by_user_id(user.id).each{|teamuser| teamuser.delete}
       AssignmentQuestionnaires.find_all_by_user_id(user.id).each{|aq| aq.destroy}           
       user.destroy
    rescue
      flash[:error] = $!
    end
    
    redirect_to :action => 'list'
  end
  
  def keys
    @user = User.find(params[:id])
    @private_key = @user.generate_keys
  end
  
  protected

  def foreign
    role = Role.find((session[:user]).role_id)  
    @all_roles = Role.find(:all, :conditions => ['id in (?) or id = ?',role.get_available_roles,role.id])
  end
 
  private

  def get_role
     if @user && @user.role_id
      @role = Role.find(@user.role_id)
    elsif @user
      @role = Role.new(:id => nil, :name => '(none)')
    end
  end

end
