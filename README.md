Expertiza 
=========
#### CSC/ECE 517 Project2 OSS 
There are three students:
<b>
username: user1,user2,user3
password: admin
</b>
 <b>Topic</b>: E1509 Refactoring SignUpController and SignUpSheetController<br>
 <b>Team member</b>: mdong3, yshang3, jli53<br>
 <b>Contact</b>: Ed Gehringer, efg@ncsu.edu, Nikhil Chinthapallee, nchinth@ncsu.edu<br>

 <b>Classes involved</b>: response.rb, and possibly other model classes<br>

 <b>What it does:</b>  Lists topics available for an assignment, checks whether a user is signed up for a topic, allows users to sign up for topics.<br>
 
 <b>What’s wrong with it</b><br>
 * These two controllers seem to do almost the same thing.  They have many of the same methods.  SignUpSheetController is much longer, and has many more recent mods, but some methods of SignUpController seem more sophisticated than SignUpSheetController.  So, your first job is to figure out if both controllers are being used.  If not, remove the unused controller.  Or, move the functions to a single controller if that makes sense to do.
 * Neither controller is at all RESTful; i.e.., its method names aren’t the standard names new, create, edit, delete, etc.  Functionality is divided differently than in a standard controller.<br>
    a. def confirm_topic(creator_id, topic_id, assignment_id)<br>
    b. def delete_signup<br>
    c. def delete_signup_for_topic(assignment_id,topic_id)<br>
    d. def other_confirmed_topic_for_user(assignment_id, creator_id)<br>
    e. def signup<br>
    f. def slotAvailable?(topic_id)
 * Functionality that should be in models is incorporated into the controller.
 * Some methods are too long and appear to do more than one thing
 * This class interfaces with assignments_controller so that a list of topics can be displayed when one is editing an assignment.  Please be careful that your changes do not affect the functionality on the Topics tab of editing an assignment; contact Nikhil Ch. (nchinth) for details.
 * Rename the controller(s) to SignupController and/or SignupSheetController.  (“Sign up”, which gets written as SignUp in camel case, is a verb, whereas “Signup” is a noun.)
 
<b>Other classes involved</b><br>
* sign_up_sheet.rb, sign_up_topic.rb, and possibly other model classes; assignments_controller.rb

<b>Our works</b><br>
* After various tests and analysis, we found that there is no code about <b>“SignUpController”</b> in routes.rb file and codes in <b>“SignUpController”</b> never got executed when we ran the project. Then we’ve made a decision that <b>“SignUpController”</b> is not used and we removed it.
* We’ve changed the function <b>“list”</b> to <b>“index”</b> in <b>“SignUpSheetController”</b> to make it more RESTful. But for some others, it is not good to combine some functions with the standard ones. For example, <b>“create”</b> function creates topics, which is one of the administrator’s functions. However <b>“signup”</b> creates a record that includes information for topic and student, which happens when student clicks <b>“signup”</b> button. We can see that <b>“create”</b> and <b>“signup”</b> are designed for different role and different usage so it is not a good idea to combine them together.
* Some functionality should appear in models rather than in controllers. For example, in <b>“SignUpSheetController”</b>, there is a sentence <b>“SignUpTopic.find_by_sql("SELECT s.id as topic_id FROM sign_up_topics s WHERE s.assignment_id = " + aid)”</b>. It’s better to put it in <b>“SignUpTopic”</b> model so we create a function called <b>“self.find_topic_id_with_assignment_id”</b> to wrap this sentence and call this function in <b>“SignUpSheetController”</b>. 
* We’ve find that lots of methods do more than one thing so we separate a long function into several concise functions and call them in the original function. Taking method <b>“create”</b> as an example, there are some preparation works and check works before or after the actual create operation. So we separate two functions <b>“update_topic_info”</b> and <b>“check_after_create”</b> from <b>“create”</b>. And we call these two functions in <b>“create”</b> method instead of executing these codes directly.
* Sometimes after making some changes, the display topics function didn’t work due to some reasons. We’ve fixed those bugs and make sure it still works after our last change.
* We have renamed the controller’s name, from <b>“SignUpSheetController”</b> to <b>“SignupSheetController”</b>. And we also make sure every reference for this controller has been changed to match the new controller name.
* There are lots of points that don’t apply to global rules. We have tried our best to find all of them and here are some examples:<br>
		a. change “users_team.size == 0” to “users_team.empty?”<br>
		b. change “:maximum => 10” to “maximum: 10”<br>
c. change “(assignment.staggered_deadline == true)?” to “	(assignment.staggered_deadline)?”<br>
d. change “if users_team.size == 0” to “if users_team.size.zero?”

 



