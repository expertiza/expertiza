E1505. Refactoring AssignmentParticipant model
=========

Classes involved: assignment_participant.rb

The AssignmentParticipant model is subclass of Participant model and is used to maintain the list of students/users participating in a given assignment.

What we did:

 1. We renamed all methods like get_scores and get_members which are prefixed with “get” in this class to follow ruby naming conventions.

 2. We found methods get_submitted_files, get_files should not be in this class. They deal with files, so we moved them to appropriate file helper classes.

 3. We found reviewed_by? , quiz_taken_by? do not belong to AssignmentParticipant model. So we moved them to appropriate models.

 4. We found methods is_reviewed_by? , quiz_taken_by? are not getting invoked from anywhere. I found that some methods we don't need them any longer and then delete these methods.

 5. We found that we don't need get_two_node_cycles, get_three_node_cycles, get_four_node_cycles, get_cycle_similarity_score, get_cycle_deviation_score in AssignmentParticipant model, so we deleted these methods.

At last, we followed the global Ruby style to revise the whole Ruby code in this project. So our version will be more readable and  concise.

Expertiza is a web application where students can submit and peer-review learning objects (articles, code, web sites, etc). It's our contribution that maked it more convinent for users to use. 

Wish you like our job! 
