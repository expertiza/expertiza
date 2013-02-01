Feature: Delete review for an assignment
  Expertiza will allow an instructor or TA to delete
  a review for an assignment for a team.

  Scenario: Instructor can delete a review for an assignment
    Given "Gehringer":"gehringer" logs into the system
      And the assignment named "foo" will exist
      And user "sjain2" is a participant of "foo"
      And user "mtreece" is a reviewer of "foo" for "sjain2"
      And user "mtreece" reviews "sjain2"
    When user deletes review of "foo" for "sjain2" by "mtreece"
      Then review of "foo" for "sjain2" by "mtreece" will not exist

  Scenario: TA can delete a review for an assignment
    Given "Titus":"titus" logs into the system
      And the assignment named "bar" will exist
      And user "sjain2" is a participant of "bar"
      And user "mtreece" is a reviewer of "bar" for "sjain2"
      And user "mtreece" reviews "sjain2"
    When user deletes review of "bar" for "sjain2" by "mtreece"
      Then review of "bar" for "sjain2" by "mtreece" will not exist
