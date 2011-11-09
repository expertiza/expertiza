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

We have done the following refactoring, and written functional tests to check our changes.

1)	administrator and instructor were in the same controller file admin_controller.rb.  Following DRY principle we have moved the instructor to a new controller, instructor_controller.rb. The common functionality between administrator and instructor has been moved to the new helper method administrator_instructor_helper.rb
2)	We have added extra functionality in admin_controller.rb. In original code for expertiza the edit for administrator and instructor. We have added edit method for both in our refactoring
3)	In assignment_signups_controller.rb the method listuser was renamed to  list_user as it was named in a non-standard manner.
4)	In course_controller.rb we changed the method name view_teaching_assistants to list_ta
5)	In invitation_controller.rb we changed variable check to team_member. This is because the check is to see if user is already in the team and since it is not actually revealing the intention by just seeing the variable, we changed it to a more meaningful name.
6)	In invitation_controller.rb we changed variable current_invs to sent_invitation. This is because the check is to see if the user has already been sent an invitation to join a team.
7)	In  menu_items_controller.rb we changed the method noview to no_view


Testing
We have added functional tests for administrator and instructor separation in instructor_controller_test.rb and in admin_controller_test.rb.

