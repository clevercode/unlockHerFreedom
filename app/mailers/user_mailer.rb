class UserMailer < ActionMailer::Base
  default from: "UHF Mail <mail@unlockherfreedom.com>"

  def confirmation_email(payment)
    @payment = payment
    @url  = 'http://unlockherfreedom.com/'
    mail(:to => payment.email, :subject => "Your payment has been successfully processed.")
  end
end
