class UserMailer < ActionMailer::Base
  default from: "UHF Donations <donations@unlockherfreedom.com>"

  def confirmation_email(payment)
    @payment = payment
    mail(:to => payment.email, :subject => "Thank you for your donation.")
  end
end
