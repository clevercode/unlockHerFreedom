class Message < ActiveRecord::Base
  attr_accessible :content, :messenger_email, :messenger_name
  validates_presence_of :content, :messenger_email, :messenger_name
end
