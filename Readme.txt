Project title : 219 Miscellaneous controller cleanup

Contributors
 - Bala Anirudh Kurakula (bkuraku)
 - Dilip Devaraj (ddilipd)
 - Vinisha Varre (vvarre)

In this project E219 Miscellaneous controller cleanup, we had to refactor the following controllers:
admin_controller
assignment_signups_controller
auth_controller
content_pages_controller
controller_actions_controller
course_controller
course_evaluation_controller
eula_controller
export_file_controller
impersonate_controller
import_file_controller
institution_controller
invitation_controller
leaderboard_controller
markup_styles_controller
menu_item_controller
participants_controller
password_retrieval_controller
permissions_controller

The main intenntion of the project was to:
1. Refactor the code which deos not follow DRY principle. 
2. Rename the variables with appropriate names so that they are meaningful 
3. Rename the functions so that they maintain consistency.
4. Maintain standards. 

We have done the following refactoring: 

1)	Refactor Administrator and Instructor into different controllers. (Major change)
   Before Change: Controller file admin_controller.rb contained functions for both administrator and instructor.  
   What are the changes? Following DRY principle we have moved the instructor to a new controller, instructor_controller.rb. 
                         The common functionality between administrator and instructor has been moved to the new helper method administrator_instructor_helper.rb.
                         All the functions related to instructor have been moved. 
   Reason: Instructors and Adminstrators are two different roles and so they neeed to be in different controllers for easo fo understanding.

2)	Addition of edit functionality: 
   Before Change: In original code for expertiza there is no edit for administrator and instructor. 
   What are the changes?: We have added edit method for both in our refactoring.
   Reason: When we click on the edit button, it throws error. Edit was implemented, maintaining the standards .

3)	Rename method:
   Before change: In assignment_signups_controller.rb the method listuser was used.
   What are the changes?: Renamed to list_user.
   Reason: It was named in a non-standard manner and was not consistent with the other names.  

4)	Rename method: 
   Before change: In course_controller.rb a method view_teaching_assistants is used.
   What are the changes?: Renamed to list_ta.
   Reason: maintain consistency with the other names.

5)	Rename Variable name:
   Before change: In invitation_controller.rb a variable check was used.
   What are the changes?: Changed the name to team_member. 
   Reason: The variable name does not give us any hint as what the variable was for. Renamed to give it a meaningful name.

6)	Rename Variable name:
   Before change: In invitation_controller.rb variable current_invs was used.
   What are the changes?: Changed to sent_invitation. 
   Reason: The check is to see if the user has already been sent an invitation to join a team. Renaming gives it a meaningful name.

7)	Rename method:
   Before change: In  menu_items_controller.rb a method noview was used.
   What are the changes: Changed name to no_view.
   Reason: maintain consistency with other naming convention. 


Testing:
Functional tests for administrator controller.
Functional tests for instructor controller.  
Functional tests to check if any user without permission is able to access the administrator previlleges. 
Functional tests to check the separation into different controlers. 

Tests files: 
instructor_controller_test.rb 
admin_controller_test.rb.

