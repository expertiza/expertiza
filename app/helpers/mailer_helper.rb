module MailerHelper
  def self.send_mail_to_user(user, subject, partial_name, password)
    Mailer.generic_message ({
      to: user.email,
      subject: subject,
      body: {
        user: user,
        password: password,
        first_name: ApplicationHelper.get_user_first_name(user),
        partial_name: partial_name
      }
    })
  end
  # This function will find if there are already reviews present for the current submission,
  # If the reviews are present then it will mail each reviewer a mail with the link to update the current review.

  def self.mail_assigned_reviewers(team)
    maps = ResponseMap.where(reviewed_object_id: @participant.assignment.id, reviewee_id: team.id, type: 'ReviewResponseMap')
    unless maps.nil?
      maps.each do |map|
        # Mailing function
        Mailer.general_email(
          to: User.find(Participant.find(map.reviewer_id).user_id).email,
          subject:  "Link to update the review for Assignment '#{@participant.assignment.name}'",
          cc: User.find_by(@participant.assignment.instructor_id).email,
          link: "Link: https://expertiza.ncsu.edu/response/new?id=#{map.id}",
          assignment: @participant.assignment.name
        ).deliver_now
      end
    end
  end

  def self.send_mail_to_all_super_users(super_user, user, subject)
    Mailer.request_user_message ({
      to: super_user.email,
      subject: subject,
      body: {
        super_user: super_user,
        user: user,
        first_name: ApplicationHelper.get_user_first_name(super_user)
      }
    })
  end
end
