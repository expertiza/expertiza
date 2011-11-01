Feature: View scores for an assignment
  Expertiza will allow an instructor or TA to view
  scores for an assignment.

  # what about testing for overall statistics?  needed?

  Scenario: Instructor can view scores of an assignment
    Given "Gehringer":"gehringer" logs into the system
      And the assignment named "foo" will exist
      And user "mtreece" is a participant of "foo"
      And user "mtreece" scored 94 on assignment "foo"
      And user "sjain2" is a participant of "foo"
      And user "sjain2" scored 96 on assignment "foo"
      And user "nobody" is a participant of "foo"
      And user "nobody" scored 0 on assignment "foo"
    When user views scores for assignment "foo"
      Then user "mtreece" will have a score of 94 for assignment "foo"
      And user "sjain2" will have a score of 96 for assignment "foo"
      And user "nobody" will have a score of 0 for assignment "foo"

  Scenario: TA can view scores of an assignment
    Given "Titus":"titus" logs into the system
      And the assignment named "bar" will exist
      And user "mtreece" is a participant of "bar"
      And user "mtreece" scored 84 on assignment "bar"
      And user "sjain2" is a participant of "bar"
      And user "sjain2" scored 86 on assignment "bar"
      And user "nobody" is a participant of "bar"
      And user "nobody" scored 1 on assignment "bar"
    When user views scores for assignment "bar"
      Then user "mtreece" will have a score of 84 for assignment "bar"
      And user "sjain2" will have a score of 86 for assignment "bar"
      And user "nobody" will have a score of 1 for assignment "bar"
