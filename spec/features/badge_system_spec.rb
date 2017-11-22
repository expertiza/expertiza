# PRECONDITIONS FOR TESTING:
#
# 1 .We need a Course
# 2. We need an Instructor for the Course
# 3. We need a Student enrolled in the Course
# 4. We need an Assignment for the Course
# 5. We need the Student to be a Participant of the Assignment
# 6. We need the Student to have a review score for the Assignment
# 7. We need the Student to have a teammate score for the Assignment
# 8. *** We might need another Student that has completed the same Assignment (so the first Student can have something to "review" for a score)
# 9. *** We might need another Student that is in the same Team as the first Student (so the first Student can have a teammate score)
#
# 1. Good Reviewer Badge
#
#   1.1. When an Instructor updates the threshold for the badge to be *below* the Student's review score
#
#     1.1.1. The badge should appear on the Student's Task List
#
#     1.1.2. The badge should appear on the Instructor's Participant List
#
#   1.2. When an Instructor updates the threshold for the badge to be *above* the Student's review score
#
#     1.2.1. The badge should *not* appear on the Student's Task List
#
#     1.2.2. The badge should *not* appear on the Instructor's Participant List
#
#   1.3. When an Instructor updates the threshold for the badge to be *equal to* the Student's review score
#
#     1.3.1. The badge should appear on the Student's Task List
#
#     1.3.2. The badge should appear on the Instructor's Participant List
#
# 2. Good Teammate Badge
#
#   2.1. When an Instructor updates the threshold for the badge to be *below* the Student's review score
#
#     2.1.1. The badge should appear on the Student's Task List
#
#     2.1.2. The badge should appear on the Instructor's Participant List
#
#   2.2. When an Instructor updates the threshold for the badge to be *above* the Student's review score
#
#     2.2.1. The badge should *not* appear on the Student's Task List
#
#     2.2.2. The badge should *not* appear on the Instructor's Participant List
#
#   2.3. When an Instructor updates the threshold for the badge to be *equal to* the Student's review score
#
#     2.3.1. The badge should appear on the Student's Task List
#
#     2.3.2. The badge should appear on the Instructor's Participant List