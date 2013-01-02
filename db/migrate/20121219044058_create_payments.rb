class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.float  :amount
      t.string :email

      t.timestamps
    end
  end
end
