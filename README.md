Expertiza
=========

[![Build Status](https://travis-ci.org/expertiza/expertiza.svg?branch=master)](https://travis-ci.org/expertiza/expertiza)
[![Code Climate](https://codeclimate.com/github/expertiza/expertiza/badges/gpa.svg)](https://codeclimate.com/github/expertiza/expertiza)
[![Coverage Status](https://coveralls.io/repos/github/expertiza/expertiza/badge.svg?branch=master)](https://coveralls.io/github/expertiza/expertiza?branch=master)
#### Peer review system

Expertiza is a web application where students can submit and peer-review learning objects (articles, code, web sites, etc). It is used in select courses at NC State and by professors at several other colleges and universities.

**Project Description:**

The existing functionality implements the email notifications' feature in response to certain events. However, there are cases where email notifications are sent which are redundant as well as cases where email notifications need to be sent but are not sent. The current project aims at improving this email-notification functionality. For example, Expertiza uses a peer review system wherein, after the first round of submission, submitted work is peer reviewed. Using the recommendations made and the improvements suggested in the peer reviews, an assignment participant can then proceed to improve his work. Thus, a participant is notified via email whenever a review for his/her submitted work is provided. Similarly, a reviewer is notified via email when a new submission is made for the work that he/she reviewed. Now, if the participant makes an improvement in his/her submission after the last round of reviews has been done, sending an email to the reviewer regarding this is redundant. However, in the current state of application, a reviewer is notified in this case too. Thus, there are similar cases, where the email notification needs to be enabled/disabled and that is the objective of our project.


**For Expertiza, emails are sent from a certain gmail account. Thus, for testing the email functionality use the following credentials:

**user_name: 'expertiza.development@gmail.com' 
password: 'qwer@1234'**

