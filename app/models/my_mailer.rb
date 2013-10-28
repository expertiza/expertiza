class My_mailer
  # To change this template use File | Settings | File Templates.
  def mail(recipient)
    @from ="sender.address@example.com"
    @recipients =recipient
    @subject="Hi #{recipient}"
    @body=(:recipient => recipient)
  end
end