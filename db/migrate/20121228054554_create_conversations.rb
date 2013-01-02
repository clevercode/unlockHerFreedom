class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.string :name
      t.string :email
      t.string :message

      t.timestamps
    end
  end
end
