class Payment < ActiveRecord::Base
  # validates_presence_of :email, :amount

  attr_accessible :amount, :email
end
