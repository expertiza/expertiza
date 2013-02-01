Feature: Assign reviewers to an assignment
  Expertiza will allow an instructor to assign
    reviewers for an assignment

  Scenario: Instructor can assign reviewers 
    Given "Gehringer":"gehringer" logs into the system             
       And the assignment named "foo" will exist
       And "sjain2" has been assigned "foo"
       And "mtreece" has been assigned "foo"
       And user has uploaded csv file "sample_reviewers.csv" containing "sjain2":"mtreece" for the assignment named "foo"
    Then the assignment named "foo" will have "sjain2":"mtreece" as reviewers
