class UserMailer < ActionMailer::Base
  default from: "UHF Donations <donations@unlockherfreedom.com>"

  def confirmation_email(payment)
    @payment = payment
    mail(:to => payment.email, :subject => "Thank you for your donation.")
  end

  def fundraiser_email(payment, guests, turns)
    @payment = payment
    @guests  = guests
    @turns   = turns
    mail(
      :from => 'UHF Events <events@unlockherfreedom.com>',
      :to => "#{payment.name} <#{payment.email}>",
      :subject => "Thank you for your contribution."
    )
  end
end
