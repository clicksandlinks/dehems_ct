class PasswordMailer < ActionMailer::Base
  
  def reset_password(email, password, sent_at = Time.now)
    @subject = "Ecoserve Password Reset"
    @recipients = email
    @from = "no-reply@clicksandlinks.com"
    @sent_on = sent_at
    @new_password = password
  end

end
