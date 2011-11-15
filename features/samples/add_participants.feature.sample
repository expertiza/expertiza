Feature: Add participants to an assignment
  Expertiza will allow an instructor or TA to add
  participants to an assignment

  Scenario: Instructor can add a participant to an assignment
    Given "Gehringer":"gehringer" logs into the system
      And the assignment named "foo" will exist
    When user adds "mtreece" to the assignment, "foo"
      Then "mtreece" will be a participant of "foo"

  Scenario: TA can add a participant to an assignment
    Given "Titus":"titus" logs into the system
      And the assignment named "bar" will exist
    When user adds "mtreece" to the assignment, "bar"
      Then "mtreece" will be a participant of "bar"
