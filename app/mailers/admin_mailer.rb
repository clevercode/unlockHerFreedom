class AdminMailer < ActionMailer::Base
  default to: 'mail@unlockherfreedom.com'

  def message_email(message)
    @message = message
    mail(
      from: "#{@message.messenger_name} <#{@message.messenger_email}>",
      subject: 'Message for the UHF team.'
    )
  end
end
