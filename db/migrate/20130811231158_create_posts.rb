class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.boolean :has_payment
      t.string :payment_title
      t.text :payment_description
      t.integer :admin_id

      t.timestamps
    end
  end
end
