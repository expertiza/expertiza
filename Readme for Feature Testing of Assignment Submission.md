# Expertiza
Expertiza is a web application where students can submit and peer-review learning objects (articles, code, web sites, etc). It is used in select courses at NC State and by professors at several other colleges and universities.

***

This repository contains information related to the Assignment E1574: Feature test for assignment submission by student.

This repository _is not_ the original repository for Expertiza. Here is the link to the original repository:
* [Original Repository](https://github.com/expertiza/expertiza)


## For the reviewer
### Overview of the Assignment
Feature test for assignment submission by student mocks the steps required in assignment submission on Expertiza. After the assignment is created by the instructor, the student can submit the assignment by taking the following steps:
* Login
* Select the assignment
* Select "Your Work"
* Upload the link or file

The goal is to test these steps using rspec and capybara.

### Running the Feature Test
To run the feature test, follow the steps
* Clone this repository
* Make sure to run bundle install and rake db:migrate
* First run the assignment_creation.rb to create the assignments
'''
$ rspec spec/features/assignment_creation.rb
'''
* Then run the student_assignment_submission_spec.rb file to run the feature tests
'''
$ rspec spec/features/student_submission_spec.rb
'''

## Background
###Feature Test



###Gems Used


## Attribution
This repository was constructed by [Shrenuj Gandhi](https://github.com/shrenujgandhi), Kunal Bhandari(), Bharghav Jhaveri() under the guidance of Yatish Mehta(). Thanks to Abhishek Lingwal, ... for their contribution in generating assignments using capybara script.
