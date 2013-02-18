class Payment < ActiveRecord::Base
  attr_accessible :amount, :email
  validates_presence_of :email, :amount
end
