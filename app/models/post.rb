class Post < ActiveRecord::Base
  attr_accessible :admin_id, :content, :has_payment, :payment_description, :payment_title, :title

  belongs_to :admin
end
