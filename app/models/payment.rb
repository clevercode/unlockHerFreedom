class Payment < ActiveRecord::Base
  attr_accessible :amount, :email
  validates_presence_of :email, :amount

  def formatted_amount
    Money.new(self.amount, 'USD').to_s
  end

end
