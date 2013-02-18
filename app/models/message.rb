class Message < ActiveRecord::Base
  attr_accessible :content, :messenger_email, :messenger_name
end
