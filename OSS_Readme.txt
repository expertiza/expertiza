OSS Projects Topic
E622. Updating invite teams functionality to prevent two teams from being formed with the same set of students
What needs to be done:

1.    To prevent two teams from being formed with the same students, code will be written to prevent user A from inviting user B to join his team if user B has already invited user A to join her team.  The message given will be something like, “You can’t invite B to join your team, because B has already invited you to join his/her team.”  

2.   Refactoring the teams_users table to be a teams_participants table (which will make debugging a lot easier, because it eliminates an indirection in figuring out who is on a team).

Team members:<in no particular order>

Sonam Chakravarti
Shruti Holla
Samarth Asthana


Implementation

a. The required functionality was inlcuded by creating new validations for the scenario described by the project statement 1)

b. The team_users table was refactored to teams_participants and all the references for the table in the code were changed using refactoring rename. 

c. New tests were inlcuded in the project code to test the new validations created.


VCL Hosting

http://152.7.98.76:3000/

GIT repository

https://github.com/Samarthasthana/ExpertizaE622



Important credentials

Role : admin
Id :admin
pwd: admin

Role : student 
Id: sam1
pwd: password

Role: Student
Id: North
pwd: password

Role: Student 
Id: Izzy
pwd: password

Role: Student 
Id: Alex
pwd: password


Steps to Test

A) Using the existing test objects 

1. Log into the system using the login Id North
2. Click on the Assignments tab in the navigation panel above
3. Select the Oss Assignment A link displayed 
4. Select the 'Your Team' link
5. Verify that 'Your team' page is displayed 
6. Verify that in the 'Received Invitations' section an invitation from 'sam1' is displayed.. If the invitation is not dispayed then login as 'sam1' and send an invitation to 'North' from 'Your team' page and continue to step 7.
7. Enter 'sam1' in the 'Invite people' textbox and click on the 'Invite' button
8. Verify that the page is reloaded and the message "You can’t invite "sam1" to join your team, because "sam1" has already invited you to join his/her team." is displayed at the top of the page.
9. Verify that NO invitation is displayed in the 'Sent invitations' section to 'sam1'.

OR

B) Creating new testing objects (assignment,topics,invitations)

1. Login as the admin user
2. Create a new assignment of team type using the manage->assignmnets->new assignments button
3. Create a new sign up sheet for the assignment created above
4. Add new topics to be chosen in the sign up sheet
5. Add the student id's to participate in the assignment just created
6. log off and login as a student user 
7. Naviagate to the assignment and select a topic
8. Sent an inviation to the another student and log off
9. Follow the steps given for A)

:)

NOTE: Please leave the invitations sent by 'sam1' to 'north' for Oss Assignment A so that others can test the functionality.

