# Preview all emails at http://localhost:3000/rails/mailers/conflict_mailer
class ConflictMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/conflict_mailer/send_conflict_email
  def send_conflict_email
    ConflictMailer.send_conflict_email
  end

end
