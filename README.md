OSS Project 
Project E217: Integrate a few of last year’s projects

Chandan Apsangi (capsang) 
Vaibhav Gumashta(vgumash)
Vartika Singh (vsingh3)

E3: Enhancements to Suggest and Approve

https://trello.com/card/board/e3-enhancements-to-suggest-and-approve/4e97910a88107fb718001fd1/4e979b7f88107fb718025fed

Checklist:
	1)	All topics on the sign-up sheet not just the student suggested ones should have a description.
	2)  Students can suggest topics for approval by the instructor.
	3)  Instructor can edit the topic, vote for it (Yes,No, Revise) and send it back to the student.
	4)	The instructor is able to comment when accepting or rejecting, as well as when sending a topic back for revision.
	5)	Once the topics are approved they should be visible in Sign-up sheet option.
	6)	Should be able to sort the list by status (initiated, awaiting revision,approved, rejected).

Steps:

	1)	Created a local branch for E3, merged the relevant commits from A and B branches.
	2)	Ensured that the functionality (as listed in the checklist) is working, and lastly re-based that branch with master. 
	3)	In case of conflicts test the feature with each of the commits separately and pick the best one.
	4)	Test each of the features listed above through local server setup.
	5)	Fix any failures/make changes to ensure that the features are working.
	6)	Run integration tests to ensure final quality.
	7)	Merge our branch E15-Notification with the Master.

How to setup and start the application:

	1)	Create a database named "pg_development" in mysql (Mysql 5.5 database server).
	2)	Download the sql dump file from http://cl.ly/2C3e1u1P1E1j0V3g0z1e 
	3)	Import this dump into the database created. To import, use: mysql -u root pg_development < 517dump-scrubbed.sql
	4)	Do rake db:migrate
	5)	Run the server.
