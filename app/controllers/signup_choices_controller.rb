require 'date'
class SignupChoicesController < ApplicationController
  scaffold :assignment_signups
  scaffold :participants
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @signup_sheet = SignupSheet.find(params[:id])
  end
  
  def back
    redirect_to :controller=> 'signup_sheets', :action=> 'list'
  end
  
  def add
    delete_choices params[:id]
    save_choices params[:id], params[:choices]
    save_choices params[:id], params[:new_answer]
    redirect_to :action => 'show', :id => params[:id]
  end
  
  def show
    @signup_sheet = SignupSheet.find(params[:id])
  end  
  
  def listanswers
    @signup_choices = SignupChoice.find(:all,
                                            :conditions => 'question_id = '+@params[:id],
                                            :order => 'id')                                                                                           
  end

 def listuser
    @result = Participant.find_by_sql("select participants.assignment_id from participants, assignment_signups"+
      " where assignment_signups.signup_id = "+@params[:signup_id]+" and participants.assignment_id = assignment_signups.assignment_id and "+
      "participants.user_id = "+session[:user].id.to_s) 
                                  
    @signups = AssignmentSignup.find(:all,
                              :conditions => 'assignment_id = '+@result[0].assignment_id.to_s+
                              ' and signup_id = '+@params[:signup_id])
    
    
    @waitlist_flag = 0
    if @signups[0].waitlist_deadline.to_s < Date.today.to_s
      @waitlist_flag = 1
    end
    
    @choice_flag = 0
    if @signups[0].end_date.to_s < Date.today.to_s
      @choice_flag = 1
    end
    
    @drop_flag = 0   
    
    @choices = SignupChoice.find(:all,
                              :conditions => 'question_id = '+@params[:id],          
                              :order => 'id')    
  end


  def new
    @signup_choice = SignupChoice.new
    @questions = Question.find_all
  end

  def create
    @signup_choice = SignupChoice.new(params[:signup_choice])
    @signup_choice.question_id = params[:question_id]    
    if @signup_choice.save
      @questionto = Question.find(:all,:conditions => ['id = ?', @params[:id]])
      flash[:notice] = 'Signup Choice was successfully created for '+@questionto[0].txt
      redirect_to :action => 'new', :id => @params[:id], :signup_id => @params[:signup_id]
    else
      @questions = Question.find_all
      render :action => 'new', :id=> @params[:id], :signup_id => @params[:signup_id]
    end
  end

  def edit
    @signup_choice = SignupChoice.find(params[:id])
  end

  def update
    @signup_choice = SignupChoice.find(params[:id])
    if @signup_choice.update_attributes(params[:signup_choice])
      flash[:notice] = 'Signup Choice was successfully updated.'
      redirect_to :action => 'show', :id => @signup_choice, :question_id => @params[:question_id], :signup_id => @params[:signup_id]
    else
      render :action => 'edit'
    end
  end

  def updateslots                   
        @signupchoice = SignupChoice.find(params[:id])
        @signupchoice.slots_occupied += 1
        @signupchoice.save
        redirect_to :controller => 'questions', :action => 'listuser', :id => @params[:signup_id]
  end

  def destroy
    SignupChoice.find(params[:id]).destroy
    redirect_to :action => 'listanswers', :id => @params[:question_id], :signup_id => @params[:signup_id]
  end
  
  private
  
  def delete_choices (signup_id)
    choices = SignupChoice.find(:all, :conditions => "signup_sheet_id = " + signup_id.to_s)
    for choice in choices
      for answer_key in params[:choices].keys
        if answer_key.to_s != choice.id.to_s
          choice.destroy
        end
      end
    end    
  end
  
  def save_choices (signup_id, object)
    if object
      # The new_question array contains all the new questions
      # that should be saved to the database
      for choice_key in object.keys
        answer = SignupChoice.new(object[choice_key])
        answer.signup_sheet_id = signup_id
        if answer.text.length > 0 && answer.total_slots.to_s.length > 0
          if (answer.total_slots > 0)
#           SignupChoice.connection.execute("insert into signup_choices (question_id,text,total_slots, signup_sheet_id) VALUES ("+answer.question_id.to_s+",'"+answer.text+"',"+answer.total_slots.to_s+","+answer.signup_sheet_id.to_s+")")            
            if answer.save
              flash[:notice] = 'Answers set added to Signup Sheet '+SignupSheet.find_by_id(signup_id).name  
            end
          else
           flash[:notice] = '<h3>Errors!</h3> <br> <ui><li> Slots need to be numbers </li></ui>' 
          end
        else
          flash[:notice] = '<h3>Errors!</h3><br> <ui> <li> Answer or Slots should not be empty </li><li> Slots need to be numbers </li></ui>'  
        end 
      end
    end  
  end
end
