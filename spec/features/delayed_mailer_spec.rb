require 'rails_helper'

expect_deadline_check('Submission deadline reminder email', 'is able to send reminder email for submission deadline to signed-up users ', "deadline_type: submission", "submission")
expect_deadline_check('Review deadline reminder email', 'is able to send reminder email for review deadline to reviewers ', "deadline_type: review", "review")
expect_deadline_check('Metareview deadline reminder email', 'is able to send reminder email for Metareview deadline to reviewers ', "deadline_type: metareview", "metareview")
expect_deadline_check('Drop Topic deadline reminder email', 'is able to send reminder email for drop topic deadline to reviewers ', "deadline_type: drop_topic", "drop_topic")
expect_deadline_check('Signup deadline reminder email', 'is able to send reminder email for signup deadline to reviewers ', "deadline_type: signup", "signup")
expect_deadline_check('Team formation deadline reminder email', 'is able to send reminder email for team formation deadline to reviewers ', "deadline_type: team_formation", "team_formation")
