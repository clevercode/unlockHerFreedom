class ChangeAmountTypeForPayments < ActiveRecord::Migration
  def up
    change_column :payments, :amount, :integer
  end

  def down
    change_column :payments, :amount, :float
  end
end
